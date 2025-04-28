#!/bin/bash
# Script to take email message from stdin and write it (with lock) to Maildir
# Version 1.0.0 - MSS 20250428

MAILDIR="$HOME/Maildir"
LOCKFILE="$MAILDIR/.delivery.lock"
LOCK_TIMEOUT=10
QUIET=0
LOGFILE=""

# Parse options
while [ $# -gt 0 ]; do
    case "$1" in
        --quiet)
            QUIET=1
            ;;
        --logfile)
            shift
            LOGFILE="$1"
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 64
            ;;
    esac
    shift
done

if [ ! -d "$MAILDIR/new" ]; then
    echo "Maildir tree not found in $MAILDIR" >&2
    exit 111
fi

# UNIQUE as in a unique file name
UNIQUE="$(hostname)-$$-$(date +%s%N)"
TMPFILE="$MAILDIR/tmp/$UNIQUE"
NEWFILE="$MAILDIR/new/$UNIQUE"

mkdir -p "$(dirname "$LOCKFILE")"

(
    flock -x -w $LOCK_TIMEOUT 200 || {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed to acquire lock within ${LOCK_TIMEOUT}s" >&2
        exit 75
    }

    dd of="$TMPFILE" status=none || exit 75
    mv --backup=numbered "$TMPFILE" "$NEWFILE" || exit 75
    MESSAGE="[$(date '+%Y-%m-%d %H:%M:%S')] Delivered message to $NEWFILE"
    if [ "$QUIET" -eq 0 ]; then
        echo "$MESSAGE"
    fi
    if [ -n "$LOGFILE" ]; then
        echo "$MESSAGE" >> "$LOGFILE"
    fi

) 200>"$LOCKFILE"

exit 0

