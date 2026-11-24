#!/bin/sh
# Read-only comparison of the dev site and production through their public endpoints.
# Prints sizes and short hashes of getdata responses, never the data itself.
# Usage: [DEV_URL=...] [PROD_URL=...] [GENES="..."] [DATASETS="..."] sh compare_prod_dev.sh
DEV=${DEV_URL:-http://localhost}
PROD=${PROD_URL:-https://fobinf.com}
GENES=${GENES:-"SOD1 GAPDH ACTB TP53 EIF2C4"}
DATASETS=${DATASETS:-"DMAP BLUEPRINT_Normals notta paul_sc zheng_sc velten_sc"}
ALIASES=${ALIASES:-"ATP6H ENSG00000134698 ENSG00000237125 NOTAGENE123"}
OUT=${OUT:-/mnt/mauricio/bloodspot/compare_prod}
mkdir -p "$OUT"

get() {  # get <url> <file> : prints the HTTP status code
  curl -sS --max-time 90 -L -o "$2" -w '%{http_code}' "$1" 2>/dev/null || echo 000
}

echo "dev:  $DEV"
echo "prod: $PROD"
dc=$(get "$DEV/" "$OUT/dev_index.html")
pc=$(get "$PROD/" "$OUT/prod_index.html")
echo "front page status: dev=$dc prod=$pc"
if [ "$pc" != "200" ]; then
  echo "production did not answer 200 at $PROD/ - set PROD_URL to the address of the app and rerun"
  exit 1
fi

echo
echo "== 1. dataset dropdown (option values in the page HTML)"
opts() { grep -o '<option[^>]*value="[^"]*"' "$1" | sed 's/.*value="//; s/"$//' | sort -u; }
opts "$OUT/dev_index.html"  > "$OUT/dev_opts.txt"
opts "$OUT/prod_index.html" > "$OUT/prod_opts.txt"
echo "options: dev=$(wc -l < "$OUT/dev_opts.txt" | tr -d ' ') prod=$(wc -l < "$OUT/prod_opts.txt" | tr -d ' ')"
if [ ! -s "$OUT/dev_opts.txt" ] || [ ! -s "$OUT/prod_opts.txt" ]; then
  echo "(an empty side means the dropdown is filled by JavaScript, not in the HTML)"
fi
echo "-- only in dev:";  comm -23 "$OUT/dev_opts.txt" "$OUT/prod_opts.txt" | tr '\n' ' '; echo
echo "-- only in prod:"; comm -13 "$OUT/dev_opts.txt" "$OUT/prod_opts.txt" | tr '\n' ' '; echo

echo
echo "== 2. getdata.php: status / bytes / short md5 (SAME = identical response)"
printf '%-8s %-18s %-22s %-22s %s\n' gene dataset dev prod result
for g in $GENES; do
  for d in $DATASETS; do
    dcode=$(get "$DEV/php/getdata.php?gene=$g&data=$d"  "$OUT/dev_${g}_${d}.json")
    pcode=$(get "$PROD/php/getdata.php?gene=$g&data=$d" "$OUT/prod_${g}_${d}.json")
    db=$(wc -c < "$OUT/dev_${g}_${d}.json"  | tr -d ' ')
    pb=$(wc -c < "$OUT/prod_${g}_${d}.json" | tr -d ' ')
    dm=$(md5sum "$OUT/dev_${g}_${d}.json"  | cut -c1-8)
    pm=$(md5sum "$OUT/prod_${g}_${d}.json" | cut -c1-8)
    if [ "$dm" = "$pm" ]; then r=SAME; else r=DIFF; fi
    printf '%-8s %-18s %-22s %-22s %s\n' "$g" "$d" "$dcode/$db/$dm" "$pcode/$pb/$pm" "$r"
    sleep 1
  done
done

echo
echo "== 3. lookUpAlias.php (first 100 characters of each response)"
for a in $ALIASES; do
  dbody=$(curl -sS --max-time 60 "$DEV/php/lookUpAlias.php?alias=$a"  2>/dev/null | cut -c1-100)
  pbody=$(curl -sS --max-time 60 "$PROD/php/lookUpAlias.php?alias=$a" 2>/dev/null | cut -c1-100)
  echo "$a"
  echo "   dev : $dbody"
  echo "   prod: $pbody"
  sleep 1
done
echo
echo "compare_prod_dev finished (raw responses are in $OUT)"
