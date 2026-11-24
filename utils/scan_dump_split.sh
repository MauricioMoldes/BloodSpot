#!/bin/sh
# Read-only: find and sanity-check the per-table dump files of the 8 production-only datasets.
D1=${D1:-/mnt/mauricio/bloodspot/bloodspot_v3.1/httpd-private/db-init/dump_split}
D2=${D2:-/mnt/mauricio/bloodspot/fobinf.com/httpd.private/db-init/archive_split}
PAT='iacobucci|beat_aml|human_sorted|leukegene|oci_aml|target_aml|valk'

rd() { case "$1" in *.gz) zcat "$1" ;; *) cat "$1" ;; esac; }

for D in "$D1" "$D2"; do
  echo "== $D"
  if [ ! -d "$D" ]; then echo "(missing)"; continue; fi
  echo "-- all files (size, name)"
  ls -la "$D" | awk 'NR>3{print $5"\t"$9}' | sort -k2 | head -80
  echo "-- subdirectories"
  ls -d "$D"/*/ 2>/dev/null | head
done

echo
echo "== checks on files matching the 8 names"
for D in "$D1" "$D2"; do
  [ -d "$D" ] || continue
  for f in "$D"/*; do
    [ -f "$f" ] || continue
    echo "$f" | grep -i -q -E "$PAT" || continue
    echo "-- $f"
    ls -la "$f" | awk '{print "   bytes:", $5}'
    case "$f" in *.gz) gzip -t "$f" 2>&1 && echo "   gzip: ok" || echo "   gzip: BAD" ;; esac
    echo "   CREATE TABLE: $(rd "$f" | grep -a -m1 -o 'CREATE TABLE `[^`]*`')"
    echo "   INSERT targets: $(rd "$f" | grep -a -o '^INSERT INTO `[^`]*`' | sort | uniq -c | tr '\n' ' ')"
    echo "   trailer: $(rd "$f" | tail -c 600 | grep -a 'Dump completed' | tail -1)"
  done
done
echo "scan_dump_split finished"
