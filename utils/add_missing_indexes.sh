#!/bin/sh
# Add gene_name_idx / probe_name_idx to dataset tables that lack them.
# Dataset table = has columns gene_name, probe_name, cell_name, cell_data.
# Default: print the ALTER statements. With argument "go": apply them.
# Skips zheng_sc (being fixed). Run again later with: SKIP_TABLES="" sh add_missing_indexes.sh go
set -eu
SKIP_TABLES=${SKIP_TABLES-zheng_sc}
stmts=$(mysql -N -B <<'SQL'
SELECT CONCAT('ALTER TABLE `', c.table_name, '` ADD INDEX ', c.column_name, '_idx (', c.column_name,
       IF(c.data_type IN ('text','mediumtext','longtext','blob','mediumblob','longblob'),'(64)',''), ');')
FROM information_schema.columns c
WHERE c.table_schema = DATABASE()
  AND c.column_name IN ('gene_name','probe_name')
  AND c.table_name IN (
        SELECT table_name FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND column_name IN ('gene_name','probe_name','cell_name','cell_data')
        GROUP BY table_name HAVING COUNT(*) = 4)
  AND NOT EXISTS (
        SELECT 1 FROM information_schema.statistics s
        WHERE s.table_schema = c.table_schema AND s.table_name = c.table_name
          AND s.column_name = c.column_name AND s.seq_in_index = 1)
ORDER BY c.table_name, c.column_name;
SQL
)
# drop skipped tables
for s in $SKIP_TABLES; do
  stmts=$(printf '%s\n' "$stmts" | grep -v "TABLE \`$s\`" || true)
done
if [ -z "$stmts" ]; then
  echo "nothing to do: all dataset tables have both indexes (skipped: ${SKIP_TABLES:-none})"
  exit 0
fi
printf '%s\n' "$stmts"
if [ "${1:-}" = "go" ]; then
  echo "== applying"
  printf '%s\n' "$stmts" | while IFS= read -r line; do
    echo "$line"
    START=$(date +%s)
    mysql -e "$line"
    echo "  done in $(( $(date +%s) - START ))s"
  done
  echo "indexes added"
else
  echo "== dry run only; add 'go' to apply"
fi
