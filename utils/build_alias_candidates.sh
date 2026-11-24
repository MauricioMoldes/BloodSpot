#!/bin/sh
# Build reviewable alias candidates in the staging database. Does NOT touch live tables.
# Usage: MART_DB=ensembl_mart_109 sh build_alias_candidates.sh
set -eu
DB=${MART_DB:-ensembl_mart_109}
LIVE=fobinf_comhemaexplorer
mysql "$DB" <<SQLEOF
DROP TABLE IF EXISTS alias_candidates, bs_map, mart_genes, bs_alias, bs_genes;

CREATE TABLE bs_genes (name VARCHAR(255) NOT NULL, PRIMARY KEY (name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT IGNORE INTO bs_genes SELECT DISTINCT CONVERT(name USING utf8mb4) FROM $LIVE.genes WHERE type='human';

CREATE TABLE bs_alias (alias VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, KEY (alias), KEY (name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO bs_alias SELECT DISTINCT CONVERT(alias USING utf8mb4), CONVERT(name USING utf8mb4) FROM $LIVE.alias;

CREATE TABLE mart_genes (gene_id INT UNSIGNED NOT NULL, ensg VARCHAR(128), symbol VARCHAR(512), KEY (gene_id), KEY (symbol(190))) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO mart_genes
  SELECT gene_id_1020_key, stable_id_1023, display_label_1074
  FROM gene__main
  WHERE name_1059 IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','X','Y','MT')
    AND display_label_1074 IS NOT NULL;

CREATE TABLE bs_map (name VARCHAR(255) NOT NULL, gene_id INT UNSIGNED NOT NULL, ensg VARCHAR(128), symbol VARCHAR(512), how VARCHAR(10) NOT NULL, KEY (name), KEY (gene_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO bs_map
  SELECT b.name, m.gene_id, m.ensg, m.symbol, 'symbol'
  FROM bs_genes b JOIN mart_genes m ON m.symbol = b.name;
INSERT INTO bs_map
  SELECT b.name, MIN(m.gene_id), MIN(m.ensg), MIN(m.symbol), 'synonym'
  FROM bs_genes b
  JOIN external_synonym__dm s ON s.external_synonym = b.name
  JOIN mart_genes m ON m.gene_id = s.gene_id_1020_key
  WHERE b.name NOT IN (SELECT name FROM bs_map)
  GROUP BY b.name
  HAVING COUNT(DISTINCT m.gene_id) = 1;

CREATE TABLE alias_candidates (alias VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, source VARCHAR(20) NOT NULL, status VARCHAR(14) NOT NULL DEFAULT 'new', KEY (alias), KEY (name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO alias_candidates (alias, name, source)
  SELECT DISTINCT ensg, name, 'ensembl_id' FROM bs_map WHERE ensg IS NOT NULL;
INSERT INTO alias_candidates (alias, name, source)
  SELECT DISTINCT symbol, name, 'ensembl_symbol' FROM bs_map WHERE symbol <> name;
INSERT INTO alias_candidates (alias, name, source)
  SELECT DISTINCT s.external_synonym, m.name, 'ensembl_synonym'
  FROM bs_map m JOIN external_synonym__dm s ON s.gene_id_1020_key = m.gene_id
  WHERE s.external_synonym <> m.name
    AND s.external_synonym NOT REGEXP '^[0-9]+\$'
    AND CHAR_LENGTH(s.external_synonym) >= 2;

UPDATE alias_candidates c JOIN bs_alias a ON a.alias = c.alias AND a.name = c.name SET c.status = 'present';
UPDATE alias_candidates c SET c.status = 'conflict' WHERE c.status = 'new' AND EXISTS (SELECT 1 FROM bs_alias a WHERE a.alias = c.alias AND a.name <> c.name);
UPDATE alias_candidates c SET c.status = 'collides_gene' WHERE c.status = 'new' AND c.alias IN (SELECT name FROM bs_genes);
UPDATE alias_candidates c JOIN (SELECT alias FROM alias_candidates GROUP BY alias HAVING COUNT(DISTINCT name) > 1) d ON d.alias = c.alias SET c.status = 'ambiguous' WHERE c.status = 'new';

SELECT how, COUNT(*) AS bloodspot_genes_mapped FROM bs_map GROUP BY how;
SELECT (SELECT COUNT(*) FROM bs_genes) AS bloodspot_human_genes, (SELECT COUNT(DISTINCT name) FROM bs_map) AS mapped_to_mart;
SELECT source, status, COUNT(*) AS n FROM alias_candidates GROUP BY source, status ORDER BY source, status;
SQLEOF
