#!/bin/sh
# Trim padded string columns and turn blank cell_data into '0'. Restartable.
# Usage: sh fix_padded_tables.sh [table ...]   (default: zheng_sc)
# - skips tables that are already clean
# - keeps an existing valid backup; never overwrites it
# - dumps to .partial first, so an interrupted dump is never taken for a backup
# Does NOT touch DMAP (its one padded population name is intentional).
set -eu
DB=fobinf_comhemaexplorer
B=${BACKUP_DIR:-/mnt/mauricio/bloodspot/backups}
mkdir -p "$B"
TABLES=${*:-zheng_sc}
for t in $TABLES; do
  echo "== $t  $(date '+%F %T')"
  dirty=$(mysql -N -e "SELECT COALESCE(SUM(CHAR_LENGTH(gene_name)<>CHAR_LENGTH(TRIM(gene_name)) OR CHAR_LENGTH(probe_name)<>CHAR_LENGTH(TRIM(probe_name)) OR CHAR_LENGTH(cell_name)<>CHAR_LENGTH(TRIM(cell_name)) OR CHAR_LENGTH(cell_data)<>CHAR_LENGTH(TRIM(cell_data)) OR cell_data=''),0) FROM $t;")
  if [ "$dirty" = "0" ]; then
    echo "already clean, skipping"
    continue
  fi
  f="$B/${t}_pre_trim.sql.gz"
  if [ -s "$f" ] && gzip -t "$f" 2>/dev/null; then
    echo "valid backup exists, keeping it"
  else
    rm -f "$B/${t}_pre_trim.sql.partial" "$B/${t}_pre_trim.sql" "$f"
    mysqldump --no-tablespaces --single-transaction "$DB" "$t" > "$B/${t}_pre_trim.sql.partial"
    test -s "$B/${t}_pre_trim.sql.partial"
    gzip -f "$B/${t}_pre_trim.sql.partial"
    mv "$B/${t}_pre_trim.sql.partial.gz" "$f"
    gzip -t "$f"
  fi
  ls -l "$f"
  mysql -e "UPDATE $t SET gene_name=TRIM(gene_name), probe_name=TRIM(probe_name), cell_name=TRIM(cell_name), cell_data=TRIM(cell_data);"
  mysql -e "UPDATE $t SET cell_data='0' WHERE cell_data='';"
  mysql -e "SELECT COUNT(*) AS total, SUM(CHAR_LENGTH(gene_name)<>CHAR_LENGTH(TRIM(gene_name)) OR CHAR_LENGTH(probe_name)<>CHAR_LENGTH(TRIM(probe_name)) OR CHAR_LENGTH(cell_name)<>CHAR_LENGTH(TRIM(cell_name)) OR CHAR_LENGTH(cell_data)<>CHAR_LENGTH(TRIM(cell_data))) AS still_padded, SUM(cell_data='') AS still_blank FROM $t;"
done
echo "fix finished  $(date '+%F %T')"
