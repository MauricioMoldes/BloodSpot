#!/bin/sh
# Read-only: index/timing check for the new datasets and tree-file location check.
DB=fobinf_comhemaexplorer
echo "== zheng job"
tail -2 /mnt/mauricio/bloodspot/backups/fix_zheng.log
for t in BLUEPRINT_Normals paul_sc; do
  echo "== $t indexes"
  mysql -e "SHOW INDEX FROM $t;" | awk -F'\t' 'NR==1 || 1 {print $3"\t"$4"\t"$5}'
  echo "== $t EXPLAIN gene_name"
  mysql -e "EXPLAIN SELECT * FROM $t WHERE gene_name='SOD1'\G" | grep -E 'type:|key:|rows:'
  echo "== $t EXPLAIN probe_name"
  mysql -e "EXPLAIN SELECT * FROM $t WHERE probe_name='SOD1'\G" | grep -E 'type:|key:|rows:'
  echo "== $t timing (gene_name)"
  START=$(date +%s)
  mysql -N -e "SELECT COUNT(*) FROM $t WHERE gene_name='SOD1';" >/dev/null
  END=$(date +%s)
  echo "seconds: $((END-START))"
done
echo "== tree files (dev repo and deployed), case-insensitive"
for d in BLUEPRINT lauridsen paul setty velten zheng; do
  echo "-- $d"
  find /mnt/mauricio/bloodspot/bloodspot_v3.1 /var/www/bloodspot -ipath '*trees*' -iname "*$d*" 2>/dev/null
done
echo "diagnose finished"
