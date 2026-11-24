#!/bin/sh
# Read-only: duplicate rows and multi-target aliases in the live alias table,
# plus an exclusive classification of conflict candidates.
L=fobinf_comhemaexplorer
S=ensembl_mart_109
echo "== live alias: rows vs distinct (alias,name) pairs"
mysql <<SQL
SELECT COUNT(*) AS rows_total,
       COUNT(DISTINCT alias, name) AS distinct_pairs,
       COUNT(*) - COUNT(DISTINCT alias, name) AS surplus_rows
FROM $L.alias;
SQL
echo "== live alias: aliases that already point to more than one distinct name"
mysql <<SQL
SELECT COUNT(*) AS multi_target_aliases FROM (
  SELECT alias FROM $L.alias GROUP BY alias HAVING COUNT(DISTINCT name) > 1) t;
SQL
echo "== conflict candidates, exclusive: does ANY current target of the alias exist as a gene?"
mysql <<SQL
SELECT source, has_live_target, COUNT(*) AS candidates FROM (
  SELECT c.source, c.alias, c.name, MAX(g.name IS NOT NULL) AS has_live_target
  FROM $S.alias_candidates c
  JOIN $L.alias a ON a.alias = CONVERT(c.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci
  LEFT JOIN $L.genes g ON g.name = a.name
  WHERE c.status = 'conflict'
  GROUP BY c.source, c.alias, c.name) t
GROUP BY source, has_live_target
ORDER BY source, has_live_target;
SQL
echo "duplicate diagnose finished"
