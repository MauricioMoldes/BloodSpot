#!/bin/sh
# Load core Ensembl mart tables into a separate staging database named after MART_DEST.
# Usage: MART_DEST=/mnt/.../grch37_ensembl_mart_109 sh ensembl_mart_load.sh
# Needs sudo for the one-time CREATE DATABASE / GRANT / local_infile step.
set -eu
D=${MART_DEST:?set MART_DEST to the local mart directory}
DB=${MART_DB:-$(basename "$D" | sed 's/^grch37_//')}
SQL=$(ls "$D"/ensembl_mart_*.sql | head -1)
P=hsapiens_gene_ensembl__
fail=0
echo "database: $DB, schema: $SQL"

sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB CHARACTER SET utf8mb4; GRANT ALL ON $DB.* TO 'bloodspot_dev'@'localhost'; SET GLOBAL local_infile=1;"

TABLES="gene__main transcript__main external_synonym__dm"
for f in "$D"/${P}efg_*__dm.txt; do
  [ -f "$f" ] || continue
  t=${f##*/${P}}; t=${t%.txt}
  TABLES="$TABLES $t"
done

for t in $TABLES; do
  full=$P$t
  file=$D/$full.txt
  [ -f "$file" ] || { echo "MISSING $file"; fail=1; continue; }
  ddl=$(awk -v t="$full" '$0 ~ "CREATE TABLE `" t "`" {p=1} p {print} p && /ENGINE=/ {exit}' "$SQL" \
        | sed "s/$P//; s/ENGINE=MyISAM DEFAULT CHARSET=latin1/ENGINE=InnoDB DEFAULT CHARSET=utf8mb4/")
  [ -n "$ddl" ] || { echo "no CREATE TABLE found for $full"; exit 1; }
  mysql "$DB" -e "DROP TABLE IF EXISTS $t"
  printf '%s\n' "$ddl" | mysql "$DB"
  mysql --local-infile=1 "$DB" <<SQLEOF
LOAD DATA LOCAL INFILE '$file' INTO TABLE $t CHARACTER SET utf8mb4 FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';
SQLEOF
  rows=$(mysql -N "$DB" -e "SELECT COUNT(*) FROM $t")
  lines=$(wc -l < "$file" | tr -d ' ')
  if [ "$rows" = "0" ]; then echo "EMPTY $t (file has $lines lines)"; fail=1
  elif [ "$rows" = "$lines" ]; then echo "OK    $t $rows rows"
  else echo "DIFF  $t table=$rows file=$lines"; fail=1; fi
done

echo "--- sanity: probe 200642_at -> gene"
mysql "$DB" -e "SELECT DISTINCT p.display_label_11056 AS probe, t.display_label_1074 AS symbol, t.stable_id_1023 AS ensg FROM efg_affy_hg_u133_plus_2__dm p JOIN transcript__main t ON t.transcript_id_1064_key = p.transcript_id_1064_key WHERE p.display_label_11056 = '200642_at';" || true
echo "--- sanity: aliases of that gene"
mysql "$DB" -e "SELECT DISTINCT s.external_synonym FROM external_synonym__dm s JOIN transcript__main t ON t.gene_id_1020_key = s.gene_id_1020_key JOIN efg_affy_hg_u133_plus_2__dm p ON p.transcript_id_1064_key = t.transcript_id_1064_key WHERE p.display_label_11056 = '200642_at' LIMIT 10;" || true

[ "$fail" = "0" ] || { echo "load finished WITH PROBLEMS (see EMPTY/DIFF/MISSING above)"; exit 1; }
echo "load clean"
