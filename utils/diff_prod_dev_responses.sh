#!/bin/sh
# Look inside the responses saved by compare_prod_dev.sh (read-only apart from a few small temp files).
OUT=${OUT:-/mnt/mauricio/bloodspot/compare_prod}
PROD=${PROD_URL:-https://fobinf.com}
rows() { grep -o '"cell_name"' "$1" | wc -l | tr -d ' '; }

echo "== rows (objects) per response"
for pair in "notta SOD1" "BLUEPRINT_Normals SOD1" "paul_sc EIF2C4" "zheng_sc TP53" "velten_sc SOD1" "velten_sc TP53"; do
  set -- $pair
  echo "$1 $2: dev=$(rows "$OUT/dev_$2_$1.json") prod=$(rows "$OUT/prod_$2_$1.json")"
done

echo
echo "== line-by-line differences (JSON split at commas; first 20 lines of each diff; \$ marks the end of a line)"
for pair in "notta SOD1" "paul_sc EIF2C4" "zheng_sc TP53" "BLUEPRINT_Normals SOD1"; do
  set -- $pair
  tr ',' '\n' < "$OUT/dev_$2_$1.json"  > "$OUT/.a.txt"
  tr ',' '\n' < "$OUT/prod_$2_$1.json" > "$OUT/.b.txt"
  echo "-- $1 $2 (< dev, > prod)"
  diff "$OUT/.a.txt" "$OUT/.b.txt" | sed -n l | head -20
done

echo
echo "== velten_sc SOD1: number of space-separated tokens in cell_data, per row"
for side in dev prod; do
  printf '%s: ' "$side"
  grep -o '"cell_data":"[^"]*"' "$OUT/${side}_SOD1_velten_sc.json" | awk '{print NF}' | tr '\n' ' '
  echo
done

echo
echo "== does production's alias target for ENSG00000134698 (AGO4) have data in DMAP?"
echo "bytes returned by production: $(curl -sS --max-time 60 "$PROD/php/getdata.php?gene=AGO4&data=DMAP" | wc -c | tr -d ' ') (2 = empty)"
echo "diff_prod_dev_responses finished"
