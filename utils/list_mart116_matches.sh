#!/bin/sh
# Read-only (apart from two scratch tables inside ensembl_mart_109):
# how do the BloodSpot names missed by 109 match mart 116, and how ambiguous are the matches?
set -eu
S=ensembl_mart_109
L=fobinf_comhemaexplorer
mysql "$S" <<SQL
DROP TABLE IF EXISTS probe116_unmatched;
DROP TABLE IF EXISTS probe116_matches;
CREATE TABLE probe116_unmatched AS
SELECT DISTINCT CONVERT(name USING utf8mb4) COLLATE utf8mb4_0900_ai_ci AS name FROM unmatched_human;
CREATE TABLE probe116_matches AS
SELECT u.name AS bs_name, 'symbol' AS how, g.gene_key, g.ensg, g.symbol
FROM probe116_unmatched u JOIN probe116_genes g ON g.symbol = u.name
UNION ALL
SELECT u.name, 'synonym', g.gene_key, g.ensg, g.symbol
FROM probe116_unmatched u
JOIN probe116_syns s ON s.synonym = u.name
JOIN probe116_genes g ON g.gene_key = s.gene_key;

SELECT 'names matched, by how' AS info;
SELECT how, COUNT(DISTINCT bs_name) AS names FROM probe116_matches GROUP BY how;

SELECT 'names by number of distinct 116 genes they point to (1 = unambiguous)' AS info;
SELECT ngenes, COUNT(*) AS names FROM (
  SELECT bs_name, COUNT(DISTINCT gene_key) AS ngenes FROM probe116_matches GROUP BY bs_name) t
GROUP BY ngenes ORDER BY ngenes;

SELECT 'matched ENSG ids already present as an alias in the live table' AS info;
SELECT COUNT(DISTINCT m.ensg) AS ensg_ids,
       SUM(EXISTS (SELECT 1 FROM $L.alias a
                   WHERE a.alias = CONVERT(m.ensg USING utf8mb4) COLLATE utf8mb4_0900_ai_ci)) AS already_in_alias
FROM (SELECT DISTINCT ensg FROM probe116_matches WHERE ensg IS NOT NULL) m;

SELECT 'sample of non-LOC matches: BloodSpot name, how, Ensembl 116 symbol, ENSG' AS info;
SELECT bs_name, how, symbol AS ensembl116_symbol, ensg
FROM probe116_matches WHERE bs_name NOT LIKE 'LOC%' ORDER BY RAND() LIMIT 25;

SELECT 'sample of LOC matches' AS info;
SELECT bs_name, how, symbol AS ensembl116_symbol, ensg
FROM probe116_matches WHERE bs_name LIKE 'LOC%' ORDER BY RAND() LIMIT 8;
SQL
echo "list_mart116_matches finished"
