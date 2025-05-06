#!/bin/bash
#
# Move files in Maildir/new to Maildir/cur
#
# marknew.sh [server1] [server2] ... [server_n]
#
# Scans each folder in the format:
#   "$DEFAULT_ROOT/images/<server>/home/Maildir/{user1,user2}/new"
# Then lists (and optionally cats) the files

version="1.0.0"

DEFAULT_ROOT="$HOME/smtp-garden/"

KNOWN_SERVERS=("aiosmtpd" "courier-msa" "courier" "dovecot" "exim" "james-maildir" "opensmtpd" "postfix")

usage() {
    cat <<EOF
usage:
$ markread.sh [OPTIONS] [server1] [server2] [...]
Version $version
Moves all files in .../Maildir/new/ to .../Maildir/cur/

OPTIONS:
--invert, -v    Invert server list (i.e. all servers except those listed)
--new, -n       Reverse move, i.e. from cur/ to new/
-u1, -u2        Isolates search to user1 or user2 respectively
                Use one or the other, not both
--help, -h      This help

SERVERS:
[server]        Specific server directories to scan.  If none are
                specified, all will be scanned.
EOF
}

move_emails() { # $2 -> IGNORE_U1; $3 -> IGNORE_U2; $4 = REVERSE
    DEFAULT_IMAGETREE="images/$1/home/"
    USER1="user1/"
    USER2="user2/"
    DEFAULT_SRC_TAIL="Maildir/new/"
    DEFAULT_DST_TAIL="Maildir/cur/"

    SRC_USER1="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER1$DEFAULT_SRC_TAIL"
    DST_USER1="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER1$DEFAULT_DST_TAIL"
    SRC_USER2="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER2$DEFAULT_SRC_TAIL"
    DST_USER2="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER2$DEFAULT_DST_TAIL"

    if "$4"; then
        temp=$SRC_USER1
        SRC_USER1=$DST_USER1
        DST_USER1=$temp
        temp=$SRC_USER2
        SRC_USER2=$DST_USER2
        DST_USER2=$temp
    fi

    echo -n "Searching $1..."; if "$4"; then echo "(reverse move)"; else echo; fi

    if ! "$2"; then
        find "$SRC_USER1" -type f -not -name '.gitignore' -exec mv -b {} "$DST_USER1" \;
    fi
    if ! "$3"; then
        find "$SRC_USER2" -type f -not -name '.gitignore' -exec mv -b {} "$DST_USER2" \;
    fi
}

INVERT=false # invert server list
REVERSE=false # reverse direction of mv
IGNORE_U1=false
IGNORE_U2=false
while [ $# -gt 0 ]; do
    case $1 in
        --invert|-v)
            INVERT=true
            shift
            ;;
        --help|-h)
            usage
            exit
            ;;
        --new|-n)
            REVERSE=true
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
    if "$INVERT"; then
        echo "Inverting server list requires listing at least one server."
        exit
    fi
    for server in "${KNOWN_SERVERS[@]}"; do
        move_emails "$server" "$IGNORE_U1" "$IGNORE_U2" "$REVERSE"
    done
    exit
fi

if "$INVERT"; then
    echo "Inverting server list..."
    NEW_LIST=()
    for server in "${KNOWN_SERVERS[@]}"; do
        [[ "$@" =~ $server ]] || NEW_LIST+=("$server")
    done

    count=${#NEW_LIST[@]}
    if [[ $count -eq 0 ]]; then
        echo "All servers ignored.  Nothing to do."
        exit
    else
        for server in "${NEW_LIST[@]}"; do
            move_emails "$server" "$IGNORE_U1" "$IGNORE_U2" "$REVERSE"
        done
    fi
else
    while [ $# -gt 0 ]; do
        if [[ ${KNOWN_SERVERS[@]} =~ $1 ]]; then
            move_emails "$1" "$IGNORE_U1" "$IGNORE_U2" "$REVERSE"
        else
            echo "Unknown server $1, ignoring"
        fi
        shift
    done
fi
