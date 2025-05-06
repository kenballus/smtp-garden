#!/bin/bash

# Scans each folder in the format:
#   "$DEFAULT_ROOT/images/<server>/home/Maildir/{user1,user2}/new"
# Sorts the files and diffs each against the first entry

version="1.0.0"

DEFAULT_ROOT="$HOME/smtp-garden"

KNOWN_SERVERS=("aiosmtpd" "courier-msa" "courier" "dovecot" "exim" "james-maildir" "opensmtpd" "postfix")

DEFAULT_MID="images/$1/home"
DEFAULT_U1="user1/Maildir/new/"
DEFAULT_U2="user2/Maildir/new/"

usage() {
    cat <<EOF
usage:
$ diffnew.sh [OPTIONS] [server1] [server2] [...]
Version $version
Scans server home folders for emails, sorts them, and diffs them
against the reference email (i.e. first in sorted order)

OPTIONS:
-u1, -u2        Isolates search to user1 or user2 respectively
                Use one or the other, not both
--help, -h      This help

SERVERS:
[server]        Specific server directories to scan.  If none are
                specified, all will be scanned.

EOF
}

IGNORE_U1=false
IGNORE_U2=false
while [ $# -gt 0 ]; do
    case $1 in
        --help|-h)
            usage
            exit
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

paths=()
second_half="Maildir/new/"
if [ $# -eq 0 ]; then # No servers specified
    echo "No servers specified, assuming \"all\""

    for server in "${KNOWN_SERVERS[@]}"; do
        first_half="$DEFAULT_ROOT/images/$server/home"
        U1="$first_half/user1/$second_half"
        U2="$first_half/user2/$second_half"

        if ! "$IGNORE_U1"; then
            paths+=($U1)
        fi
        if ! "$IGNORE_U2"; then
            paths+=($U2)
        fi
    done
else # manually select servers
    for server in "$@"; do
        if [[ ${KNOWN_SERVERS[@]} =~ $server ]]; then
            first_half="$DEFAULT_ROOT/images/$server/home"
            U1="$first_half/user1/$second_half"
            U2="$first_half/user2/$second_half"

            if ! "$IGNORE_U1"; then
                paths+=($U1)
            fi
            if ! "$IGNORE_U2"; then
                paths+=($U2)
            fi
        else
            echo "Skipping unknown server $server"
        fi
    done
fi

count=${#paths[@]}
if [[ $count -eq 0 ]]; then
    echo "No servers/users selected"
    exit
fi

files=()
for path in "${paths[@]}"; do
    [[ -d "$path" ]] || continue
    while IFS= read -r -d $'\0' file; do
        files+=("$file")
    done < <(find "$path" -type f ! -name ".gitignore" -print0)
done

IFS=$'\n' files=($(sort <<<"${files[*]}"))
unset IFS

count=${#files[@]}

if [[ $count -eq 0 ]]; then
    echo "No files found"
elif [[ $count -eq 1 ]]; then
    echo "Found 1 file: ${files[0]}"
else
    echo "Found $count files"
    ref="${files[0]}"
    for ((i=1; i<count; i++)); do
        echo -e "**** Diffing:\n1: '${files[i]}'\n2: '${ref}'\n****"
        diff "$ref" "${files[i]}"
        echo "**** END DIFF ****"
    done
fi
