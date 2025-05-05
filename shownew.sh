#!/bin/bash
#
# list (and optionally cat) files in Maildir
#
# shownew.sh [-c|--cat] [server1] [server2] ... [server_n]
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
$ shownew.sh [-h, --help] [-c, --cat] [server1] [server2] [...]
Version $version

ARGUMENTS:
--help, -h      This help
--cat, -c       Print contents of all files found to stdout
[server]        Specific server directories to scan

Note: if no servers are listed, all will be scanned.

EOF
}

explore_dir() {
    DEFAULT_MID="images/$1/home/"
    DEFAULT_U1="user1/Maildir/new/"
    DEFAULT_U2="user2/Maildir/new/"

    U1="$DEFAULT_ROOT$DEFAULT_MID$DEFAULT_U1"
    U2="$DEFAULT_ROOT$DEFAULT_MID$DEFAULT_U2"

    echo "Scanning $1 ..."

    if "$CAT"; then
        find "$U1" -type f -not -name '.gitignore' -exec bash -c 'echo -e "\n***** {} ****"; cat "{}"; echo "***** EOF *****"' \;
        find "$U2" -type f -not -name '.gitignore' -exec bash -c 'echo -e "\n***** {} ****"; cat "{}"; echo "***** EOF *****"' \;
    else
        find "$U1" -type f -not -name '.gitignore'
        find "$U2" -type f -not -name '.gitignore'
    fi

}

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
         -*)
            echo "Unknown argument $1, try $0 --help"
            exit
            ;;
          *)
            break
            ;;
    esac
done

if [ $# -eq 0 ]; then
    echo "No servers specified, assuming \"all\""
    for server in "${KNOWN_SERVERS[@]}"; do
        explore_dir $server
    done
fi

while [ $# -gt 0 ]; do
    if [[ ${KNOWN_SERVERS[@]} =~ $1 ]]; then
        explore_dir "$1"
    else
        echo "Unknown server $1, ignoring"
    fi
    shift
done

