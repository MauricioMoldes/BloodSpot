#!/bin/sh
# deploy_www.sh -- copy code from the dev repo to the copy Apache serves.
# Never touches: httpd-private/libraries/db.php (local credentials), www/surv/ (extracted plots), httpd-private/db-init/ (dumps).
# Usage: sudo sh deploy_www.sh        dry run, lists what would change
#        sudo sh deploy_www.sh go     copies the files
DEV="/mnt/mauricio/bloodspot/bloodspot_v3.1"
DEP="/var/www/bloodspot"
if [ "$(id -u)" -ne 0 ]; then echo "Run with sudo."; exit 1; fi

MODE="-n"
[ "$1" = "go" ] && MODE=""
OPTS="-rl -c -i --exclude=*.bak_* $MODE"

sync_dir() { # name, extra rsync excludes
    NAME="$1"; shift
    LIST="${TMPDIR:-/tmp}/deploy_$NAME.$$"
    echo "== $NAME =="
    rsync $OPTS "$@" "$DEV/$NAME/" "$DEP/$NAME/" | tee "$LIST"
    if [ -z "$MODE" ]; then
        grep '^>f' "$LIST" | cut -d' ' -f2- | while IFS= read -r f; do
            chown www-data:www-data "$DEP/$NAME/$f"
        done
    fi
    rm -f "$LIST"
}

sync_dir www --exclude=/surv/
sync_dir httpd-private --exclude=/db-init/ --exclude=/libraries/db.php

if [ -z "$MODE" ]; then
    echo "Deployed. Hard-refresh the browser (Ctrl+Shift+R)."
else
    echo "Dry run only. Apply with: sudo sh deploy_www.sh go"
fi
