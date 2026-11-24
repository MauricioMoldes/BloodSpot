#!/bin/sh
# Read-only: show the layout of alias_candidates and 8 random rows per risky group.
S=ensembl_mart_109
echo "== layout"
mysql "$S" -e "DESCRIBE alias_candidates;"
for combo in "ensembl_synonym conflict" "ensembl_synonym ambiguous" "ensembl_synonym collides_gene" "ensembl_synonym new" "ensembl_id conflict" "ensembl_symbol conflict"; do
  set -- $combo
  echo "== source=$1 status=$2"
  mysql "$S" -e "SELECT * FROM alias_candidates WHERE source='$1' AND status='$2' ORDER BY RAND() LIMIT 8;"
done
echo "sample finished"
