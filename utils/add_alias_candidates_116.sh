#!/bin/sh
# Supplement: add aliases for BloodSpot names that mart 109 could not match but mart 116 can.
# Uses the scratch tables probe116_* inside ensembl_mart_109.
# Default is a dry run (everything is rolled back). Use "go" to back up and commit.
set -eu
L=fobinf_comhemaexplorer
S=ensembl_mart_109
B=${BACKUP_DIR:-/mnt/mauricio/bloodspot/backups}
MODE=${1:-dry}

ai=$(mysql -N -e "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='$L' AND table_name='alias' AND column_name='id' AND extra LIKE '%auto_increment%';")
if [ "$ai" != "1" ]; then
  echo "ABORT: alias.id is not AUTO_INCREMENT, so a plain INSERT would not be safe"
  exit 1
fi
have=$(mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$S' AND table_name='probe116_matches';")
if [ "$have" != "1" ]; then
  echo "ABORT: $S.probe116_matches not found (run list_mart116_matches.sh first)"
  exit 1
fi

if [ "$MODE" = "go" ]; then
  mkdir -p "$B"
  mysqldump --no-tablespaces --single-transaction "$L" alias > "$B/alias_pre_merge_116.sql"
  test -s "$B/alias_pre_merge_116.sql"
  gzip -f "$B/alias_pre_merge_116.sql"
  gzip -t "$B/alias_pre_merge_116.sql.gz"
  ls -l "$B/alias_pre_merge_116.sql.gz"
  END_SQL="COMMIT;"
else
  echo "DRY RUN: everything below is rolled back"
  END_SQL="ROLLBACK;"
fi

mysql "$S" <<SQL
DROP TABLE IF EXISTS probe116_single;
DROP TABLE IF EXISTS probe116_add;
DROP TABLE IF EXISTS probe116_multi;

CREATE TABLE probe116_single AS
SELECT bs_name FROM probe116_matches GROUP BY bs_name HAVING COUNT(DISTINCT gene_key) = 1;

CREATE TABLE probe116_add AS
SELECT DISTINCT m.ensg AS alias, m.bs_name AS name, 'ensg_symbolmatch' AS kind
FROM probe116_matches m
WHERE m.how = 'symbol' AND m.ensg IS NOT NULL
UNION
SELECT DISTINCT m.ensg, m.bs_name, 'ensg_synonymmatch'
FROM probe116_matches m JOIN probe116_single s ON s.bs_name = m.bs_name
WHERE m.how = 'synonym' AND m.ensg IS NOT NULL
UNION
SELECT DISTINCT m.symbol, m.bs_name, 'symbol_synonymmatch'
FROM probe116_matches m JOIN probe116_single s ON s.bs_name = m.bs_name
WHERE m.how = 'synonym' AND m.symbol IS NOT NULL AND m.symbol <> m.bs_name;

SELECT 'candidate aliases before filters, by kind' AS info;
SELECT kind, COUNT(*) AS n FROM probe116_add GROUP BY kind;

DELETE FROM probe116_add WHERE CHAR_LENGTH(alias) < 3 OR alias REGEXP '^[0-9]+\$';

DELETE a FROM probe116_add a
WHERE EXISTS (SELECT 1 FROM $L.alias x
              WHERE x.alias = CONVERT(a.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci);
DELETE a FROM probe116_add a
WHERE EXISTS (SELECT 1 FROM $L.genes g
              WHERE g.name = CONVERT(a.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci);
DELETE a FROM probe116_add a
WHERE NOT EXISTS (SELECT 1 FROM $L.genes g
              WHERE g.name = CONVERT(a.name USING utf8mb4) COLLATE utf8mb4_0900_ai_ci);

CREATE TABLE probe116_multi AS
SELECT alias FROM probe116_add GROUP BY alias HAVING COUNT(DISTINCT name) > 1;
DELETE a FROM probe116_add a JOIN probe116_multi m ON m.alias = a.alias;

SELECT 'rows that pass all filters, by kind' AS info;
SELECT kind, COUNT(*) AS n FROM probe116_add GROUP BY kind;

SELECT 'sample of what would be added: alias, BloodSpot name, kind' AS info;
SELECT alias, name, kind FROM probe116_add ORDER BY RAND() LIMIT 20;

START TRANSACTION;
SELECT COUNT(*) AS alias_rows_before FROM $L.alias;
INSERT INTO $L.alias (alias, name) SELECT alias, name FROM probe116_add;
SELECT COUNT(*) AS alias_rows_after FROM $L.alias;
$END_SQL
SQL
echo "add_alias_candidates_116 finished ($MODE)"
