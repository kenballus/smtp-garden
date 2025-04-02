#!/bin/bash
GARDEN_DIR=~/smtp-garden/images

find "$GARDEN_DIR"/dovecot/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/courier/home -type f -not -name '.gitignore' -not -name ".courier" -delete
find "$GARDEN_DIR"/courier-msa/home -type f -not -name '.gitignore' -not -name ".courier" -delete
find "$GARDEN_DIR"/exim/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/james/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/james/inbox -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/opensmtpd/home -type f -not -name '.gitignore' -delete
find "$GARDEN_DIR"/postfix/home -type f -not -name '.gitignore' -delete
