#!/bin/bash

# Purge inboxes of old messages (i.e., all non-essential files in Docker
# volumes).  Update $GARDEN_DIR for your system.

GARDEN_DIR=~/smtp-garden/images

find "$GARDEN_DIR"/aiosmtpd/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/courier/home -type f -not -name '.gitignore' -not -name ".courier" -not -name "dumplog.sh" -delete
find "$GARDEN_DIR"/courier-msa/home -type f -not -name '.gitignore' -not -name ".courier" -not -name "dumplog.sh" -delete
find "$GARDEN_DIR"/dovecot/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/exim/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/james/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/james/inbox -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/james-maildir/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/james-maildir/inbox -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/opensmtpd/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/postfix/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/sendmail/spool -type f -not -name '.gitignore' -delete
