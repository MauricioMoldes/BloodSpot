#!/bin/sh
# Read-only: compare conflicting alias candidates with the current live alias targets.
# Conversion is applied on the staging side only, so the live alias index can be used.
L=fobinf_comhemaexplorer
S=ensembl_mart_109
echo "== conflicts by source and whether the current live target is a real gene"
mysql <<SQL
SELECT c.source,
       (g.name IS NOT NULL) AS current_target_is_gene,
       COUNT(DISTINCT c.alias, c.name) AS candidates
FROM $S.alias_candidates c
JOIN $L.alias a ON a.alias = CONVERT(c.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci
LEFT JOIN $L.genes g ON g.name = a.name
WHERE c.status = 'conflict'
GROUP BY c.source, current_target_is_gene
ORDER BY c.source, current_target_is_gene;
SQL
for src in ensembl_synonym ensembl_id ensembl_symbol; do
  echo "== samples: $src (alias | candidate target | current live target | current target is a gene)"
  mysql <<SQL
SELECT c.alias, c.name AS candidate_name, a.name AS current_name, (g.name IS NOT NULL) AS current_is_gene
FROM $S.alias_candidates c
JOIN $L.alias a ON a.alias = CONVERT(c.alias USING utf8mb4) COLLATE utf8mb4_0900_ai_ci
LEFT JOIN $L.genes g ON g.name = a.name
WHERE c.status = 'conflict' AND c.source = '$src'
ORDER BY RAND() LIMIT 12;
SQL
done
echo "conflict sample finished"
