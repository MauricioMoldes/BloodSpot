#!/bin/sh
# Download (resumable) and verify an Ensembl BioMart mysql dump folder.
# Usage: MART_URL=<dir url, trailing slash> MART_DEST=<local dir> sh ensembl_mart_fetch.sh [go]
#   (no argument = dry run: list files, sizes, free space, files empty on the server)
# Optional: MART_EXCLUDE=<egrep pattern of file names to skip> (default: transcript_variation)
set -eu
URL=${MART_URL:?set MART_URL to the mart directory URL (with trailing slash)}
DEST=${MART_DEST:?set MART_DEST to the local destination directory}
EXCLUDE=${MART_EXCLUDE:-transcript_variation}
MODE=${1:-dry}
mkdir -p "$DEST"
LIST=$DEST/.filelist
SIZES=$DEST/.sizes

curl -fsS "$URL" | grep -o 'href="[^"?/][^"]*"' | sed 's/^href="//; s/"$//' | grep -v '/$' > "$LIST.all" || true
grep -v -E "$EXCLUDE" "$LIST.all" > "$LIST" || true
n=$(wc -l < "$LIST" | tr -d ' ')
nall=$(wc -l < "$LIST.all" | tr -d ' ')
[ "$n" -gt 0 ] || { echo "no files left to download at $URL"; exit 1; }
echo "listed: $nall files, skipping $((nall - n)) matching '$EXCLUDE', selected: $n"

: > "$SIZES"
empty_core=0
while IFS= read -r f; do
  s=$(curl -fsSI "$URL$f" | awk 'tolower($1)=="content-length:"{gsub("\r","",$2); print $2}')
  if [ -z "$s" ] || [ "$s" = "0" ]; then
    echo "EMPTY ON SERVER: $f"
    case $f in
      *__gene__main.txt|*__transcript__main.txt|*__external_synonym__dm.txt) empty_core=1 ;;
    esac
    s=0
  fi
  printf '%s %s\n' "$s" "$f" >> "$SIZES"
done < "$LIST"

total=$(awk '{t+=$1} END{printf "%.0f", t}' "$SIZES")
avail_kb=$(df -Pk "$DEST" | awk 'NR==2{print $4}')
echo "source: $URL"
echo "selected total: $(awk -v t="$total" 'BEGIN{printf "%.2f", t/1073741824}') GiB"
echo "free in $DEST: $(awk -v k="$avail_kb" 'BEGIN{printf "%.0f", k/1048576}') GiB"
echo "largest selected files:"
sort -rn "$SIZES" | head -8

if [ "$empty_core" != "0" ]; then
  echo "ABORT: a core table (gene__main / transcript__main / external_synonym__dm) is empty on the server."
  exit 1
fi
if [ "$MODE" != "go" ]; then echo "Dry run only. Apply with: sh $0 go"; exit 0; fi

need_kb=$(awk -v t="$total" 'BEGIN{printf "%.0f", t/1024*1.2}')
[ "$avail_kb" -ge "$need_kb" ] || { echo "Not enough free space."; exit 1; }

while read -r size f; do
  [ "$size" = "0" ] && continue
  if [ -f "$DEST/$f" ] && [ "$(wc -c < "$DEST/$f" | tr -d ' ')" = "$size" ]; then continue; fi
  echo "downloading $f"
  curl -fSL -C - --retry 5 --retry-delay 5 -o "$DEST/$f" "$URL$f"
  got=$(wc -c < "$DEST/$f" | tr -d ' ')
  [ "$got" = "$size" ] || { echo "SIZE MISMATCH $f ($got vs $size)"; exit 1; }
done < "$SIZES"

if [ -f "$DEST/CHECKSUMS" ]; then
  : > "$DEST/.verify"
  awk '{print $1+0, $2+0, $3}' "$DEST/CHECKSUMS" | while read -r c b f; do
    [ -f "$DEST/$f" ] || continue
    got=$(cd "$DEST" && sum "$f" | awk '{print $1+0, $2+0}')
    if [ "$got" = "$c $b" ]; then echo "OK $f" >> "$DEST/.verify"; else echo "BAD $f" >> "$DEST/.verify"; fi
  done
  echo "checksums: $(grep -c '^OK' "$DEST/.verify" || true) ok, $(grep -c '^BAD' "$DEST/.verify" || true) bad"
else
  echo "no CHECKSUMS file; relying on size checks"
fi
echo "done: $(ls "$DEST" | wc -l | tr -d ' ') entries in $DEST"
