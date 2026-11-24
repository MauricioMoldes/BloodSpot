#!/bin/sh
# How many BloodSpot human names that mart 109 could not match would mart 116 match?
# Loads gene id/symbol and synonyms of 116 into two throwaway tables inside ensembl_mart_109
# (probe116_genes, probe116_syns) using generated INSERTs (no LOAD DATA LOCAL). Prints counts only.
set -eu
OUT=${OUT:-/mnt/mauricio/bloodspot/ensembl/grch38_mart_116_probe}
SCHEMA=$OUT/ensembl_mart_116.sql.gz
GENES=$OUT/hsapiens_gene_ensembl__gene__main.txt.gz
SYNS=$OUT/hsapiens_gene_ensembl__external_synonym__dm.txt.gz
S=ensembl_mart_109
P=hsapiens_gene_ensembl

order() {  # order <table> : column names in file order
  gunzip -c "$SCHEMA" | awk -v t="${P}__$1" '
    index($0, "CREATE TABLE `" t "`") == 1 { p = 1; next }
    p && /^\)/ { exit }
    p && /^ *`/ { gsub(/^ *`|`.*$/, ""); print }'
}
pos() {  # pos <orderfile> <column> : 1-based position or empty
  awk -v c="$2" '$0 == c { print NR }' "$1"
}

order gene__main > "$OUT/order_gene__main.txt"
order external_synonym__dm > "$OUT/order_external_synonym__dm.txt"

kpos=$(pos "$OUT/order_gene__main.txt" gene_id_1020_key)
spos=$(pos "$OUT/order_gene__main.txt" stable_id_1023)
lpos=$(pos "$OUT/order_gene__main.txt" display_label_1074)
if [ -z "$kpos" ] || [ -z "$spos" ] || [ -z "$lpos" ]; then
  echo "ABORT: expected columns not found in gene__main of release 116"; exit 1
fi
skey=$(pos "$OUT/order_external_synonym__dm.txt" gene_id_1020_key)
if [ -z "$skey" ] || [ "$(wc -l < "$OUT/order_external_synonym__dm.txt" | tr -d ' ')" != "2" ]; then
  echo "ABORT: unexpected layout of external_synonym__dm"; exit 1
fi
sval=$((3 - skey))
echo "gene__main positions: key=$kpos ensg=$spos symbol=$lpos; synonym column position: $sval"

gunzip -c "$GENES" | awk -F'\t' -v k="$kpos" -v s="$spos" -v l="$lpos" 'BEGIN{OFS="\t"} {print $k, $s, $l}' > "$OUT/genes116.tsv"
gunzip -c "$SYNS"  | awk -F'\t' -v k="$skey" -v v="$sval" 'BEGIN{OFS="\t"} {print $k, $v}' > "$OUT/syns116.tsv"
echo "extracted: $(wc -l < "$OUT/genes116.tsv" | tr -d ' ') genes, $(wc -l < "$OUT/syns116.tsv" | tr -d ' ') synonym rows"

# tsv -> multi-row INSERT statements (500 rows each); \N and values with a backslash become NULL
awk -F'\t' '
  function q(s) {
    if (s == "" || s == "\\N" || index(s, "\\")) return "NULL"
    gsub(/\047/, "\047\047", s)
    return "\047" s "\047"
  }
  function num(s) { return (s ~ /^[0-9]+$/) ? s : "NULL" }
  BEGIN { print "SET NAMES utf8mb4;" }
  { if (n % 500 == 0) { if (n > 0) print ";"; printf "INSERT INTO probe116_genes (gene_key, ensg, symbol) VALUES " } else printf ","
    printf "(%s,%s,%s)", num($1), q($2), q($3); n++ }
  END { if (n > 0) print ";" }' "$OUT/genes116.tsv" > "$OUT/genes116.sql"
awk -F'\t' '
  function q(s) {
    if (s == "" || s == "\\N" || index(s, "\\")) return "NULL"
    gsub(/\047/, "\047\047", s)
    return "\047" s "\047"
  }
  function num(s) { return (s ~ /^[0-9]+$/) ? s : "NULL" }
  BEGIN { print "SET NAMES utf8mb4;" }
  { if (n % 500 == 0) { if (n > 0) print ";"; printf "INSERT INTO probe116_syns (gene_key, synonym) VALUES " } else printf ","
    printf "(%s,%s)", num($1), q($2); n++ }
  END { if (n > 0) print ";" }' "$OUT/syns116.tsv" > "$OUT/syns116.sql"

mysql "$S" <<SQL
DROP TABLE IF EXISTS probe116_genes;
DROP TABLE IF EXISTS probe116_syns;
CREATE TABLE probe116_genes (gene_key INT, ensg VARCHAR(64), symbol VARCHAR(255), KEY (symbol)) DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE TABLE probe116_syns (gene_key INT, synonym VARCHAR(255), KEY (synonym)) DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
SQL
mysql "$S" < "$OUT/genes116.sql"
mysql "$S" < "$OUT/syns116.sql"
mysql "$S" -e "SELECT COUNT(*) AS genes116, SUM(symbol IS NOT NULL) AS with_symbol FROM probe116_genes; SELECT COUNT(*) AS synonyms116 FROM probe116_syns;"

namecol=$(mysql -N -e "SELECT column_name FROM information_schema.columns WHERE table_schema='$S' AND table_name='unmatched_human' ORDER BY ordinal_position LIMIT 1;")
echo "unmatched_human: using first column '$namecol' as the gene name"

mysql "$S" <<SQL
CREATE TEMPORARY TABLE u AS
SELECT DISTINCT CONVERT(\`$namecol\` USING utf8mb4) COLLATE utf8mb4_0900_ai_ci AS name
FROM unmatched_human;
SELECT COUNT(*) AS unmatched_names_in_109, SUM(name LIKE 'LOC%') AS loc_names FROM u;
SELECT
  SUM(EXISTS (SELECT 1 FROM probe116_genes g WHERE g.symbol = u.name)) AS match_116_symbol,
  SUM(EXISTS (SELECT 1 FROM probe116_syns s WHERE s.synonym = u.name)) AS match_116_synonym,
  SUM(EXISTS (SELECT 1 FROM probe116_genes g WHERE g.symbol = u.name)
   OR EXISTS (SELECT 1 FROM probe116_syns s WHERE s.synonym = u.name)) AS match_116_either,
  SUM(name NOT LIKE 'LOC%' AND (EXISTS (SELECT 1 FROM probe116_genes g WHERE g.symbol = u.name)
   OR EXISTS (SELECT 1 FROM probe116_syns s WHERE s.synonym = u.name))) AS match_116_either_non_loc
FROM u;
SQL
echo "compare_mart116_unmatched finished"
