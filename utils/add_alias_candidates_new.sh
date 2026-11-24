#!/bin/sh
# Tier 1 alias merge: add status='new' candidates to the live alias table.
# SOURCES (default ensembl_id,ensembl_symbol) limits which candidate sources are used.
# Default is a dry run (everything is rolled back). Use "go" to back up and commit.
set -eu
L=fobinf_comhemaexplorer
S=ensembl_mart_109
B=${BACKUP_DIR:-/mnt/mauricio/bloodspot/backups}
MODE=${1:-dry}
SOURCES=${SOURCES:-ensembl_id,ensembl_symbol}
SRC_SQL=$(printf '%s' "$SOURCES" | sed "s/[^,]*/'&'/g")
echo "sources: $SOURCES"

ai=$(mysql -N -e "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='$L' AND table_name='alias' AND column_name='id' AND extra LIKE '%auto_increment%';")
if [ "$ai" != "1" ]; then
  echo "ABORT: alias.id is not AUTO_INCREMENT, so a plain INSERT would not be safe"
  exit 1
fi

if [ "$MODE" = "go" ]; then
  mkdir -p "$B"
  mysqldump --no-tablespaces --single-transaction "$L" alias > "$B/alias_pre_merge_new.sql"
  test -s "$B/alias_pre_merge_new.sql"
  gzip -f "$B/alias_pre_merge_new.sql"
  gzip -t "$B/alias_pre_merge_new.sql.gz"
  ls -l "$B/alias_pre_merge_new.sql.gz"
  END_SQL="COMMIT;"
else
  echo "DRY RUN: everything below is rolled back"
  END_SQL="ROLLBACK;"
fi

mysql <<SQL
SELECT 'candidates with status new, by source' AS info;
SELECT source, COUNT(*) AS n FROM $S.alias_candidates
WHERE status = 'new' AND source IN ($SRC_SQL) GROUP BY source;

CREATE TEMPORARY TABLE tmp_add AS
SELECT DISTINCT c.alias AS alias, c.name AS name, c.source AS source
FROM $S.alias_candidates c
WHERE c.status = 'new'
  AND c.source IN ($SRC_SQL)
  AND CHAR_LENGTH(c.alias) >= 3
  AND c.alias NOT REGEXP '^[0-9]+\$'
  AND EXISTS (SELECT 1 FROM $L.genes g
              WHERE g.name = CONVERT(c.name USING utf8mb4) COLLATE utf8mb4_0900_ai_ci)
  AND NOT EXISTS (SELECT 1 FROM $L.alias a
              WHERE a.alias = CONVERT(c.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci);

CREATE TEMPORARY TABLE tmp_multi AS
SELECT alias FROM tmp_add GROUP BY alias HAVING COUNT(DISTINCT name) > 1;
DELETE t FROM tmp_add t JOIN tmp_multi m ON m.alias = t.alias;

SELECT 'rows that pass the filters, by source' AS info;
SELECT source, COUNT(*) AS n FROM tmp_add GROUP BY source;

START TRANSACTION;
SELECT COUNT(*) AS alias_rows_before FROM $L.alias;
INSERT INTO $L.alias (alias, name) SELECT alias, name FROM tmp_add;
SELECT COUNT(*) AS alias_rows_after FROM $L.alias;
$END_SQL
SQL
echo "add_alias_candidates_new finished ($MODE)"
