#!/bin/sh
# Read-only: which tables does the 19G dump define, and where; what does the dump's dataset registry say?
F=${1:-/mnt/mauricio/bloodspot/fobinf.com/httpd.private/db-init/01-init-db.sql}
OUT=${OUT:-/mnt/mauricio/bloodspot/dump_scan}
mkdir -p "$OUT"
[ -f "$F" ] || { echo "dump not found: $F"; exit 1; }
echo "dump: $F ($(ls -la "$F" | awk '{print $5}') bytes)"

echo
echo "== 1. loader logic (load_monolith.sh lines 30-100)"
sed -n 30,100p utils/load_monolith.sh

echo
echo "== 2. one pass over the dump (CREATE TABLE offsets + dataset registry INSERT)"
date
grep -a -b -E '^(CREATE TABLE |INSERT INTO `dataset` )' "$F" | cut -c1-6000 > "$OUT/dump_scan.txt"
date
echo "-- CREATE TABLE statements in the dump (byte offset, table)"
grep -a 'CREATE TABLE' "$OUT/dump_scan.txt" | sed 's/^\([0-9]*\):CREATE TABLE `\([^`]*\)`.*/\1 \2/' | sort -n | awk '{printf "%s %s", $1, $2; if (prev) printf "  (prev table %.0f MB)", ($1-prev)/1048576; printf "\n"; prev=$1}'
echo "tables defined: $(grep -a -c 'CREATE TABLE' "$OUT/dump_scan.txt")"

echo
echo "== 3. dataset registry rows inside the dump (names only)"
grep -a 'INSERT INTO `dataset`' "$OUT/dump_scan.txt" | head -1 | sed 's/^[0-9]*://' | grep -a -o "([0-9]*,'[^']*','[^']*','[^']*')" | awk -F"'" '{print $2" | "$6" | "$4}'
echo "scan_dump_tables finished"
