#!/bin/sh
# Read-only: locate the big dump, see how datasets are registered.
DB=${DB:-fobinf_comhemaexplorer}

echo "== 1. dataset registry table"
mysql "$DB" -e "SHOW CREATE TABLE dataset\G" | sed -n '1,40p'
mysql -N "$DB" -e "SELECT COUNT(*) FROM dataset;"
echo "-- registry rows (name | list | description)"
mysql -N "$DB" -e "SELECT dataset_name, list, LEFT(dataset_desription,60) FROM dataset ORDER BY dataset_name;"
echo "-- registry rows without a data table, and tables not in the registry"
mysql -N "$DB" -e "SELECT 'no_table', dataset_name FROM dataset WHERE dataset_name NOT IN (SELECT table_name FROM information_schema.tables WHERE table_schema='$DB');"
mysql -N "$DB" -e "SELECT 'not_registered', table_name FROM information_schema.tables WHERE table_schema='$DB' AND table_name NOT IN (SELECT dataset_name FROM dataset);"

echo
echo "== 2. what the loader scripts reference"
grep -n -i -E '\.sql|\.gz|\.tar|/mnt|dump|monolith' utils/load_monolith.sh | head -30
grep -n -i -E 'Beat_AML|TARGET_AML|LEUKEGENE|valk_aml|OCI_AML8227|human_sorted|Iacobucci' utils/v3_debug_scan.sh utils/load_monolith.sh | head -20

echo
echo "== 3. big files under /mnt/mauricio (>500 MB, depth 4)"
find /mnt/mauricio -maxdepth 4 -type f -size +500M -exec ls -la {} \; 2>/dev/null | head -30

echo
echo "== 4. production-only dataset folders on disk"
ls -d /var/www/bloodspot/www/surv/survplotsPNG/*/ 2>/dev/null | sed 's|.*/survplotsPNG/||' | tr '\n' ' '; echo
ls /mnt/mauricio/bloodspot/fobinf.com 2>/dev/null | head -20
echo "find_dump_and_registry finished"
