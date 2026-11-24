#!/bin/sh
# load_prod_datasets.sh -- load the 6 production-only datasets that exist as per-table dumps
# (the 2 others, LEUKEGENE_ and TARGET_AML, have no dump file).
# Default is a DRY RUN (prints the plan). Real load:
#   GO=1 nohup sh utils/load_prod_datasets.sh > /dev/null 2>&1 &     then: tail -f /mnt/mauricio/bloodspot/load_prod_datasets.log
# Usage: [GO=1] sh load_prod_datasets.sh [table ...]
D=${D:-/mnt/mauricio/bloodspot/bloodspot_v3.1/httpd-private/db-init/dump_split}
DB=${DB:-fobinf_comhemaexplorer}
BK=${BK:-/mnt/mauricio/bloodspot/backups}
REPO=${REPO:-/mnt/mauricio/bloodspot/bloodspot_v3.1}
LOG=${LOG:-/mnt/mauricio/bloodspot/load_prod_datasets.log}
ERR=${ERR:-/mnt/mauricio/bloodspot/load_prod_datasets.err}
GO=${GO:-0}
if [ $# -gt 0 ]; then
  TABLES="$*"
else
  TABLES="OCI_AML8227_enriched_PXD020586 OCI_AML8227_all_PXD020586 valk_aml_by_karyotype Age_stratified_AML_Iacobucci_2019_ Beat_AML human_sorted_single_cell"
fi

log() { echo "$(date '+%F %T') $*" | tee -a "$LOG"; }
q() { mysql -N "$DB" -e "$1"; }

if [ "$GO" = 1 ]; then log "MODE: LOAD"; else log "MODE: DRY RUN (set GO=1 to load)"; fi
mkdir -p "$BK"

# ---- registry backup (once) -------------------------------------------------
REGBK="$BK/dataset_pre_prod_load.sql.gz"
if [ "$GO" = 1 ]; then
  if [ -s "$REGBK" ] && gzip -t "$REGBK" 2>/dev/null; then
    log "registry backup already present: $REGBK"
  else
    mysqldump --no-tablespaces "$DB" dataset 2>>"$ERR" | gzip > "$REGBK"
    gzip -t "$REGBK" 2>/dev/null && [ "$(wc -c < "$REGBK")" -gt 300 ] || { log "ERROR: registry backup failed, aborting"; exit 1; }
    log "registry backup written: $REGBK"
  fi
fi

for t in $TABLES; do
  f="$D/$t.sql.gz"
  c="$D/${t}_corr_insert.sql.gz"
  log "===== $t"
  [ -f "$f" ] || { log "$t: MISSING $f, skipping"; continue; }
  gzip -t "$f" 2>/dev/null || { log "$t: BAD gzip $f, skipping"; continue; }

  exp=$(zcat "$f" | grep -a -c "^INSERT INTO .$t. VALUES")
  have=$(q "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB' AND table_name='$t';")
  n=-1
  [ "$have" = 1 ] && n=$(q "SELECT COUNT(*) FROM \`$t\`;")
  reg=$(q "SELECT COUNT(*) FROM dataset WHERE dataset_name='$t';")
  log "$t: dump rows=$exp, dev rows=$n, registry rows=$reg"

  if [ "$n" = "$exp" ] && [ "$reg" = 1 ]; then
    log "$t: table + registry already complete, skipping table"
  elif [ "$GO" != 1 ]; then
    log "$t: WOULD load table ($exp rows) and replace registry row"
  else
    q "DELETE FROM dataset WHERE dataset_name='$t';"
    : > "$ERR"
    START=$(date +%s)
    ( echo "SET autocommit=0; SET unique_checks=0;"; zcat "$f"; echo "COMMIT;" ) \
      | mysql --max_allowed_packet=256M "$DB" 2>"$ERR"
    RC=$?
    log "$t: load exit code $RC, $(( ($(date +%s) - START) / 60 )) min"
    if [ "$RC" -ne 0 ] || [ -s "$ERR" ]; then
      log "ERROR: first errors:"; head -5 "$ERR" | tee -a "$LOG"; exit 1
    fi
    n=$(q "SELECT COUNT(*) FROM \`$t\`;")
    reg=$(q "SELECT COUNT(*) FROM dataset WHERE dataset_name='$t';")
    log "$t: after load rows=$n (expected $exp), registry rows=$reg"
    [ "$n" = "$exp" ] && [ "$reg" = 1 ] || { log "ERROR: mismatch for $t, stopping"; exit 1; }
  fi

  # ---- correlations ---------------------------------------------------------
  if [ -f "$c" ]; then
    gzip -t "$c" 2>/dev/null || { log "$t: BAD gzip $c, skipping corr"; continue; }
    cexp=$(zcat "$c" | grep -a -c '^INSERT INTO corr ')
    cn=$(q "SELECT COUNT(*) FROM corr WHERE dataset='$t';")
    log "$t: corr dump rows=$cexp, dev corr rows=$cn"
    if [ "$cn" = "$cexp" ]; then
      log "$t: corr already complete, skipping"
    elif [ "$cn" != 0 ]; then
      log "ERROR: $t has $cn corr rows but the dump has $cexp. Not touching it; look at it by hand."; exit 1
    elif [ "$GO" != 1 ]; then
      log "$t: WOULD load corr ($cexp rows)"
    else
      : > "$ERR"
      START=$(date +%s)
      ( echo "SET autocommit=0; SET unique_checks=0; SET foreign_key_checks=0;"; zcat "$c"; echo "COMMIT;" ) \
        | mysql --max_allowed_packet=256M "$DB" 2>"$ERR"
      RC=$?
      log "$t: corr load exit code $RC, $(( ($(date +%s) - START) / 60 )) min"
      if [ "$RC" -ne 0 ] || [ -s "$ERR" ]; then
        log "ERROR: first errors:"; head -5 "$ERR" | tee -a "$LOG"; exit 1
      fi
      cn=$(q "SELECT COUNT(*) FROM corr WHERE dataset='$t';")
      log "$t: corr after load=$cn (expected $cexp)"
      [ "$cn" = "$cexp" ] || { log "ERROR: corr mismatch for $t, stopping"; exit 1; }
    fi
  else
    log "$t: no corr_insert file"
  fi
done

# ---- verification (counts only, no values) -----------------------------------
log "===== verification"
for t in $TABLES; do
  have=$(q "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB' AND table_name='$t';")
  [ "$have" = 1 ] || { log "verify $t: no table"; continue; }
  stats=$(q "SELECT COUNT(*), IFNULL(SUM(BINARY gene_name<>BINARY TRIM(gene_name) OR BINARY probe_name<>BINARY TRIM(probe_name) OR BINARY cell_name<>BINARY TRIM(cell_name) OR BINARY cell_data<>BINARY TRIM(cell_data)),0), IFNULL(SUM(TRIM(cell_data)=''),0) FROM \`$t\`;" | tr '\t' ' ')
  idx=$(q "SELECT COUNT(DISTINCT index_name) FROM information_schema.statistics WHERE table_schema='$DB' AND table_name='$t';")
  lf=$(q "SELECT list FROM dataset WHERE dataset_name='$t' LIMIT 1;")
  found=$(find "$REPO/www" -name "$lf" -print -quit 2>/dev/null)
  trees=$(ls "$REPO/www/D3/trees" 2>/dev/null | grep -i -c "$t")
  log "verify $t: rows/padded/blank=$stats indexes=$idx list=$lf found=${found:-NO} trees=$trees"
done
log "load_prod_datasets finished"
