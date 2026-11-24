#!/bin/sh
# Small look at the human tables of the GRCh38 mart for Ensembl 116 (about 6-7 MB downloaded).
# Compares row counts and column names of gene__main and external_synonym__dm with the loaded 109 staging DB.
set -eu
REL=${REL:-116}
BASE=https://ftp.ensembl.org/pub/release-$REL/mysql/ensembl_mart_$REL/
OUT=${OUT:-/mnt/mauricio/bloodspot/ensembl/grch38_mart_${REL}_probe}
mkdir -p "$OUT"

get() {  # get <file>   (skip if already complete)
  f=$1
  if [ ! -s "$OUT/$f" ]; then
    curl -fsS --max-time 600 -o "$OUT/$f" "$BASE$f"
  fi
}

SCHEMA=ensembl_mart_$REL.sql.gz
size=$(curl -fsSI --max-time 60 "$BASE$SCHEMA" | awk 'tolower($1)=="content-length:"{gsub("\r","",$2); print $2}')
echo "== schema file $SCHEMA: ${size:-unknown} bytes"
if [ -n "$size" ] && [ "$size" -gt 300000000 ]; then
  echo "schema file is too large for this probe, stopping"; exit 1
fi
get "$SCHEMA"
gzip -t "$OUT/$SCHEMA"

for t in gene__main external_synonym__dm; do
  get "hsapiens_gene_ensembl__$t.txt.gz"
  gzip -t "$OUT/hsapiens_gene_ensembl__$t.txt.gz"
  echo "== $t"
  echo "rows in release $REL: $(gunzip -c "$OUT/hsapiens_gene_ensembl__$t.txt.gz" | wc -l | tr -d ' ')"
  echo "rows in loaded 109:   $(mysql ensembl_mart_109 -N -e "SELECT COUNT(*) FROM $t;")"
  gunzip -c "$OUT/$SCHEMA" | awk -v t="hsapiens_gene_ensembl__$t" '
    index($0, "CREATE TABLE `" t "`") == 1 { p = 1; next }
    p && /^\)/ { exit }
    p && /^ *`/ { gsub(/^ *`|`.*$/, ""); print }' | sort > "$OUT/cols_${REL}_$t.txt"
  mysql ensembl_mart_109 -N -e "SELECT column_name FROM information_schema.columns WHERE table_schema='ensembl_mart_109' AND table_name='$t' ORDER BY column_name;" | sort > "$OUT/cols_109_$t.txt"
  echo "columns: release $REL = $(wc -l < "$OUT/cols_${REL}_$t.txt" | tr -d ' '), 109 = $(wc -l < "$OUT/cols_109_$t.txt" | tr -d ' ')"
  echo "-- only in $REL:"; comm -23 "$OUT/cols_${REL}_$t.txt" "$OUT/cols_109_$t.txt" | tr '\n' ' '; echo
  echo "-- only in 109:"; comm -13 "$OUT/cols_${REL}_$t.txt" "$OUT/cols_109_$t.txt" | tr '\n' ' '; echo
done
echo "probe_mart116_human finished"
