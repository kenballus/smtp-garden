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
$ markread.sh [-h, --help] [server1] [server2] [...]
Version $version
Moves all files in .../Maildir/new/ to .../Maildir/cur/

ARGUMENTS:
--help, -h      This help
[server]        Specific server directories to scan

Note: if no servers are listed, all will be scanned.

EOF
}

move_emails() {
    DEFAULT_IMAGETREE="images/$1/home/"
    USER1="user1/"
    USER2="user2/"
    DEFAULT_SRC_TAIL="Maildir/new/"
    DEFAULT_DST_TAIL="Maildir/cur/"

    SRC_USER1="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER1$DEFAULT_SRC_TAIL"
    DST_USER1="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER1$DEFAULT_DST_TAIL"
    SRC_USER2="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER2$DEFAULT_SRC_TAIL"
    DST_USER2="$DEFAULT_ROOT$DEFAULT_IMAGETREE$USER2$DEFAULT_DST_TAIL"

    echo "Searching $1..."
    find "$SRC_USER1" -type f -not -name '.gitignore' -exec mv {} "$DST_USER1" \;
    find "$SRC_USER2" -type f -not -name '.gitignore' -exec mv {} "$DST_USER2" \;
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    usage
    exit
fi

if [ $# -eq 0 ]; then
    echo "No servers specified, assuming \"all\""
    for server in "${KNOWN_SERVERS[@]}"; do
        move_emails "$server"
    done
fi

while [ $# -gt 0 ]; do
    if [[ ${KNOWN_SERVERS[@]} =~ $1 ]]; then
        move_emails "$1"
    else
        echo "Unknown server $1, ignoring"
    fi
    shift
done
