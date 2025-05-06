#!/bin/bash
#
# Scans each folder in the format:
#   "$DEFAULT_ROOT/images/<server>/home/Maildir/{user1,user2}/new"
# Then lists (and optionally cats) the files

version="1.0.0"
CAT=false

DEFAULT_ROOT="$HOME/smtp-garden/"

KNOWN_SERVERS=("aiosmtpd" "courier-msa" "courier" "dovecot" "exim" "james-maildir" "opensmtpd" "postfix")

usage() {
    cat <<EOF
usage:
$ shownew.sh [OPTIONS] [server1] [server2] [...]
Version $version
Scans server home folders for emails, and optionally prints
them to stdout.

OPTIONS:
--cat, -c       Print contents of all files found to stdout
-u1, -u2        Isolates search to user1 or user2 respectively
                Use one or the other, not both.
--help, -h      This help

SERVERS:
[server]        Specific server directories to scan.  If none are
                specified, all will be scanned.

EOF
}

explore_dir() { # $2 -> IGNORE_U1; $3 -> IGNORE_U2
    DEFAULT_MID="images/$1/home/"
    DEFAULT_U1="user1/Maildir/new/"
    DEFAULT_U2="user2/Maildir/new/"

    U1="$DEFAULT_ROOT$DEFAULT_MID$DEFAULT_U1"
    U2="$DEFAULT_ROOT$DEFAULT_MID$DEFAULT_U2"

    echo "Scanning $1 ..."

    if "$CAT"; then
        if ! "$2"; then
            find "$U1" -type f -not -name '.gitignore' -exec bash -c 'echo -e "\n***** {} ****"; cat "{}"; echo "***** EOF *****"' \;
        fi
        if ! "$3"; then
            find "$U2" -type f -not -name '.gitignore' -exec bash -c 'echo -e "\n***** {} ****"; cat "{}"; echo "***** EOF *****"' \;
        fi
    else
        if ! "$2"; then
            find "$U1" -type f -not -name '.gitignore'
        fi
        if ! "$3"; then
            find "$U2" -type f -not -name '.gitignore'
        fi
    fi
}

IGNORE_U1=false
IGNORE_U2=false
while [ $# -gt 0 ]; do
    case $1 in
        --help|-h)
            usage
            exit
            ;;
        --cat|-c)
            CAT=true
            shift
            ;;
        -u1)
            IGNORE_U2=true
            shift
            ;;
        -u2)
            IGNORE_U1=true
            shift
            ;;
        -*)
            echo "Unknown argument $1, try $0 --help"
            exit
            ;;
        *)
            break
            ;;
    esac
done

if "$IGNORE_U1" && "$IGNORE_U2"; then
    echo "Don't use -u1 and -u2 together. Try $0 --help"
    exit
fi

if [ $# -eq 0 ]; then
    echo "No servers specified, assuming \"all\""
    for server in "${KNOWN_SERVERS[@]}"; do
        explore_dir "$server" "$IGNORE_U1" "$IGNORE_U2"
    done
fi

while [ $# -gt 0 ]; do
    if [[ ${KNOWN_SERVERS[@]} =~ $1 ]]; then
        explore_dir "$1" "$IGNORE_U1" "$IGNORE_U2"
    else
        echo "Unknown server $1, ignoring"
    fi
    shift
done

