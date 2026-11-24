#!/bin/sh
# Read-only status check for the six tables handled by fix_padded_tables.sh.
DB=fobinf_comhemaexplorer
B=${BACKUP_DIR:-/mnt/mauricio/bloodspot/backups}
echo "== running queries (should be none besides this one)"
mysql -e "SELECT id, time, LEFT(info,80) AS query FROM information_schema.processlist WHERE command<>'Sleep' AND id<>CONNECTION_ID();"
echo "== backups"
ls -l --time-style=long-iso "$B"/*_pre_trim.sql.gz 2>&1
for t in BLUEPRINT_Normals lauridsen_sc paul_sc setty_sc velten_sc zheng_sc; do
  echo "== $t"
  f="$B/${t}_pre_trim.sql.gz"
  if [ -s "$f" ]; then
    gzip -t "$f" 2>&1 && echo "backup gzip OK" || echo "backup CORRUPT/INCOMPLETE"
  else
    echo "backup MISSING"
  fi
  mysql -e "SELECT COUNT(*) AS total, SUM(CHAR_LENGTH(gene_name)<>CHAR_LENGTH(TRIM(gene_name)) OR CHAR_LENGTH(probe_name)<>CHAR_LENGTH(TRIM(probe_name)) OR CHAR_LENGTH(cell_name)<>CHAR_LENGTH(TRIM(cell_name)) OR CHAR_LENGTH(cell_data)<>CHAR_LENGTH(TRIM(cell_data))) AS still_padded, SUM(cell_data='') AS still_blank FROM $t;"
done
echo "check finished"
