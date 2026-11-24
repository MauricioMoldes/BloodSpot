#!/bin/sh
# Read-only: structure of the 6 per-table dumps, the corr_insert format, free space. Row values are masked.
D=${D:-/mnt/mauricio/bloodspot/bloodspot_v3.1/httpd-private/db-init/dump_split}
DB=${DB:-fobinf_comhemaexplorer}
T="Age_stratified_AML_Iacobucci_2019_ Beat_AML OCI_AML8227_all_PXD020586 OCI_AML8227_enriched_PXD020586 valk_aml_by_karyotype human_sorted_single_cell"

mask() { awk '{i=index($0,"VALUES"); h=substr($0,1,i+5); r=substr($0,i+6); gsub(/[A-Za-z]/,"A",r); gsub(/[0-9]/,"9",r); print h r}'; }

for t in $T; do
  f="$D/$t.sql.gz"
  echo "=================== $t"
  echo "-- gzip -l: $(gzip -l "$f" | tail -1)"
  echo "-- first statements (DROP/CREATE/LOCK/ALTER)"
  zcat "$f" | grep -a -m6 -E '^(DROP TABLE|CREATE TABLE|LOCK TABLES|ALTER TABLE|SET )' | cut -c1-200
  echo "-- CREATE TABLE block"
  zcat "$f" | awk '/^CREATE TABLE/{p=1} p{print} /ENGINE=/{if(p) exit}'
  echo "-- registry row"
  zcat "$f" | grep -a -m1 '^INSERT INTO `dataset`' | cut -c1-300
  echo "-- first data INSERT (values masked)"
  zcat "$f" | grep -a -m1 "^INSERT INTO \`$t\`" | cut -c1-300 | mask
done

echo
echo "=================== corr_insert files (syntax)"
for t in Age_stratified_AML_Iacobucci_2019_ Beat_AML valk_aml_by_karyotype; do
  echo "-- $t: first 300 chars"
  zcat "$D/${t}_corr_insert.sql.gz" | head -c 300; echo
  echo "-- lines: $(zcat "$D/${t}_corr_insert.sql.gz" | wc -l | tr -d ' ')"
done

echo
echo "=================== dev schema to compare against"
mysql "$DB" -e "SHOW CREATE TABLE velten_sc\G" | sed -n '3,20p'
mysql "$DB" -e "SHOW CREATE TABLE corr\G" | sed -n '3,20p'
mysql -N "$DB" -e "SELECT table_rows FROM information_schema.tables WHERE table_schema='$DB' AND table_name='corr';"

echo
echo "=================== disk space"
df -h /var/lib/mysql /mnt/mauricio | cat
echo "inspect_dump_split finished"
