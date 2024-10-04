#!/usr/bin/bash
<<Header
Script:   restic-backup.sh
Date:     24.01.2022
Author:   Technat (Nathanael Liechti)
Version:  0.0
History   User    Date        Change
          technat 24.01.2022  Initial Version 1.0
Description: a backup script backing up the necessary files on a Nextcloud server using restic
Cronjob: @daily /var/www/restic-backup.sh
Dependency: restic, pg_dump
Docs: https://restic.readthedocs.io/en/latest/ 

© Technat

Header

###############
# Variables
###############

# Source vars
DATA_DIR="/data/nc"
WEBROOT_DIR="/var/www/technat.cloud"
DB_NAME="ncdb" 

# Restic
ENV_FILE="/var/www/.restic-env"

###############
# Checks
###############
command -v restic >/dev/null 2>&1 || { echo >&2 "restic is not installed.  Aborting."; exit 1; }
if [ ! -f "$ENV_FILE" ]; then
    echo "$ENV_FILE does not exist. Aborting"
    exit 1
else
  source $ENV_FILE
fi
if [[ $RESTIC_PASSWORD == "" ]]
then
  echo >&2 "\$RESTIC_PASSWORD is not set. Aborting"; exit 1
fi
if [[ $RESTIC_REPOSITORY == "" ]]
then
  echo >&2 "\$RESTIC_REPOSITORY is not set. Aborting"; exit 1
fi
if [[ $AWS_ACCESS_KEY_ID == "" ]]
then
  echo >&2 "\$AWS_ACCESS_KEY_ID is not set. Aborting"; exit 1
fi
if [[ $AWS_SECRET_ACCESS_KEY == "" ]]
then
  echo >&2 "\$AWS_SECRET_ACCESS_KEY is not set. Aborting"; exit 1
fi

###############
# Main Script
###############

# Enable maintenance mode
php $WEBROOT_DIR/occ maintenance:mode --on

# backup data dir 
restic backup -v $DATA_DIR

# backup webroot
restic backup -v $WEBROOT_DIR

# db dump
pg_dump -U www-data -w $DB_NAME -F p | restic backup -v --stdin --stdin-filename $DB_NAME"_dump.sql"

# disable maintenance mode
php $WEBROOT_DIR/occ maintenance:mode --off

# forget and prune old backups
restic forget -q --prune --keep-hourly 24 --keep-daily 7
