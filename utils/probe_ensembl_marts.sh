#!/bin/sh
# Read-only: find BioMart folders for several releases and report the size of the key files.
# Control: release 109 (known to work). A size of 0 or "none" = empty on the server.
RELEASES=${RELEASES:-"109 114 115 116"}
for r in $RELEASES; do
  for parent in "https://ftp.ensembl.org/pub/grch37/release-$r/mysql/" "https://ftp.ensembl.org/pub/release-$r/mysql/"; do
    listing=$(curl -fsS --max-time 60 "$parent" 2>/dev/null || true)
    if [ -z "$listing" ]; then
      echo "[$r] $parent -> not reachable"
      continue
    fi
    marts=$(printf '%s\n' "$listing" | grep -o 'href="[^"]*mart[^"]*/"' | sed 's/^href="//; s/"$//')
    echo "[$r] $parent -> mart dirs: ${marts:-none}"
    for m in $marts; do
      files=$(curl -fsS --max-time 60 "$parent$m" 2>/dev/null | grep -o 'href="[^"?/][^"]*"' | sed 's/^href="//; s/"$//' | grep -E 'gene__main\.txt|transcript__main\.txt|external_synonym__dm\.txt' || true)
      if [ -z "$files" ]; then
        echo "    $m -> key files not found"
        continue
      fi
      for f in $files; do
        s=$(curl -fsSI --max-time 60 "$parent$m$f" 2>/dev/null | awk 'tolower($1)=="content-length:"{gsub("\r","",$2); print $2}')
        echo "    $m$f  size=${s:-none}"
      done
    done
  done
done
echo "probe finished"
