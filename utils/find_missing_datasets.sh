#!/bin/sh
# Read-only: where could the 8 production-only datasets come from?
DB=${DB:-fobinf_comhemaexplorer}
BASE=${BASE:-/mnt/mauricio/bloodspot}
PAT='iacobucci|beat|human_sorted|leukegene|oci_aml|target|valk'

echo "== 1. tables in $DB matching the 8 names (name, approx rows, MB)"
mysql -N "$DB" -e "SELECT table_name, table_rows, ROUND((data_length+index_length)/1048576,1)
  FROM information_schema.tables WHERE table_schema='$DB' AND LOWER(table_name) REGEXP '$PAT' ORDER BY table_name;"
echo "total tables in $DB: $(mysql -N "$DB" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB';")"

echo
echo "== 2. how the dropdown list is built"
echo "-- www/php/getDataset.php"
sed -n 1,60p www/php/getDataset.php
echo "-- lookups in the PHP code"
grep -n -i 'dataset' www/php/db.php | head -30

echo
echo "== 3. non-data tables that might register datasets (names only)"
mysql -N "$DB" -e "SELECT table_name FROM information_schema.tables WHERE table_schema='$DB' AND LOWER(table_name) REGEXP 'dataset|data_set|meta|info|description|tree|source' ORDER BY table_name;"

echo
echo "== 4. candidate dump / source files under $BASE"
ls -laS "$BASE" 2>/dev/null | head -40
for d in "$BASE"/*/; do
  n=$(ls "$d" 2>/dev/null | grep -i -c -E "$PAT|\.sql|\.gz|\.csv|\.tsv")
  [ "$n" -gt 0 ] && { echo "-- $d ($n matching entries)"; ls -la "$d" 2>/dev/null | grep -i -E "$PAT|\.sql|\.gz|\.csv|\.tsv" | head -15; }
done

echo
echo "== 5. the 8 names inside the repo (trees, json, php)"
grep -rIl -i -E 'Beat_AML|TARGET_AML|LEUKEGENE|valk_aml|OCI_AML8227|human_sorted_single_cell|Iacobucci' www utils 2>/dev/null | head -20
ls www/D3/trees 2>/dev/null | grep -i -E "$PAT" | head -20
echo "find_missing_datasets finished"
