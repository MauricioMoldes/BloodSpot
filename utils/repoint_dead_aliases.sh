#!/bin/sh
# Tier 2 alias repair: replace dead alias targets with the Ensembl-derived BloodSpot gene name.
# Only exact-case alias rows whose targets are all missing from genes are changed.
# SOURCES (default ensembl_id,ensembl_symbol) limits which candidate sources are used.
# Default is a dry run (rolled back). Use "go" to back up and commit.
set -eu
L=fobinf_comhemaexplorer
S=ensembl_mart_109
B=${BACKUP_DIR:-/mnt/mauricio/bloodspot/backups}
MODE=${1:-dry}
SOURCES=${SOURCES:-ensembl_id,ensembl_symbol}
SRC_SQL=$(printf '%s' "$SOURCES" | sed "s/[^,]*/'&'/g")
echo "sources: $SOURCES"

if [ "$MODE" = "go" ]; then
  mkdir -p "$B"
  mysqldump --no-tablespaces --single-transaction "$L" alias > "$B/alias_pre_repoint_dead.sql"
  test -s "$B/alias_pre_repoint_dead.sql"
  gzip -f "$B/alias_pre_repoint_dead.sql"
  gzip -t "$B/alias_pre_repoint_dead.sql.gz"
  ls -l "$B/alias_pre_repoint_dead.sql.gz"
  END_SQL="COMMIT;"
else
  echo "DRY RUN: everything below is rolled back"
  END_SQL="ROLLBACK;"
fi

mysql <<SQL
CREATE TEMPORARY TABLE tmp_cand AS
SELECT DISTINCT c.source AS source, c.alias AS alias, c.name AS name
FROM $S.alias_candidates c
WHERE c.status = 'conflict'
  AND c.source IN ($SRC_SQL)
  AND EXISTS (SELECT 1 FROM $L.genes g
              WHERE g.name = CONVERT(c.name USING utf8mb4) COLLATE utf8mb4_0900_ai_ci);

CREATE TEMPORARY TABLE tmp_cand_multi AS
SELECT alias FROM tmp_cand GROUP BY alias HAVING COUNT(DISTINCT name) > 1;
DELETE t FROM tmp_cand t JOIN tmp_cand_multi m ON m.alias = t.alias;

CREATE TEMPORARY TABLE tmp_state AS
SELECT t.source AS source, t.alias AS alias, t.name AS name,
       COUNT(a.id) AS n_rows, MAX(g.name IS NOT NULL) AS has_live
FROM tmp_cand t
JOIN $L.alias a
  ON a.alias = CONVERT(t.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci
 AND CAST(a.alias AS BINARY) = CAST(t.alias AS BINARY)
LEFT JOIN $L.genes g ON g.name = a.name
GROUP BY t.source, t.alias, t.name;

CREATE TEMPORARY TABLE tmp_fix AS
SELECT source, alias, name, n_rows FROM tmp_state WHERE has_live = 0;

SELECT 'aliases to repoint, by source' AS info;
SELECT source, COUNT(*) AS aliases, SUM(n_rows) AS rows_to_update FROM tmp_fix GROUP BY source;

SELECT 'random sample: alias, current (dead) target, new target' AS info;
SELECT f.source, f.alias, a.name AS old_target, f.name AS new_target
FROM tmp_fix f
JOIN $L.alias a
  ON a.alias = CONVERT(f.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci
 AND CAST(a.alias AS BINARY) = CAST(f.alias AS BINARY)
ORDER BY RAND() LIMIT 15;

START TRANSACTION;
UPDATE $L.alias a
JOIN tmp_fix f
  ON a.alias = CONVERT(f.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci
 AND CAST(a.alias AS BINARY) = CAST(f.alias AS BINARY)
SET a.name = f.name;
SELECT ROW_COUNT() AS alias_rows_updated;
$END_SQL
SQL
echo "repoint_dead_aliases finished ($MODE)"
