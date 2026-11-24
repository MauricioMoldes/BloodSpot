#!/bin/sh
# Compare the dataset dropdown of dev and production through php/getDataset.php (read-only).
# The options look like: <option name='dataset' value='velten_sc' >label</option>
DEV=${DEV_URL:-http://localhost}
PROD=${PROD_URL:-https://fobinf.com}
OUT=${OUT:-/mnt/mauricio/bloodspot/compare_prod}
mkdir -p "$OUT"

dcode=$(curl -sS --max-time 60 -L -o "$OUT/dev_datasets.html"  -w '%{http_code}' "$DEV/php/getDataset.php"  2>/dev/null || echo 000)
pcode=$(curl -sS --max-time 60 -L -o "$OUT/prod_datasets.html" -w '%{http_code}' "$PROD/php/getDataset.php" 2>/dev/null || echo 000)
echo "status: dev=$dcode prod=$pcode"

parse() {  # option values, one per line
  tr '\n' ' ' < "$1" | sed 's/<\/option>/\n/g' | sed -n "s/.*value='\([^']*\)'.*/\1/p" | sort -u
}
parse "$OUT/dev_datasets.html"  > "$OUT/dev_datasets.txt"
parse "$OUT/prod_datasets.html" > "$OUT/prod_datasets.txt"
echo "datasets: dev=$(wc -l < "$OUT/dev_datasets.txt" | tr -d ' ') prod=$(wc -l < "$OUT/prod_datasets.txt" | tr -d ' ') in both=$(comm -12 "$OUT/dev_datasets.txt" "$OUT/prod_datasets.txt" | wc -l | tr -d ' ')"
echo "-- only in dev (not yet on production):"
comm -23 "$OUT/dev_datasets.txt" "$OUT/prod_datasets.txt" | tr '\n' ' '; echo
echo "-- only in production (not loaded in dev):"
comm -13 "$OUT/dev_datasets.txt" "$OUT/prod_datasets.txt" | tr '\n' ' '; echo
echo "compare_dataset_lists finished"
