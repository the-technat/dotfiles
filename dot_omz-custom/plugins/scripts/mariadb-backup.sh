#!/usr/bin/bash
<<Header
Script:   mariadb-backup.sh
Date:     7.12.2021
Author:   Nathanael Liechti
Version:  0.1
History   User    Date        Change
          technat 7.12.2021  Initial Version 0.1
Description: Backup Script for MariaDB Database
Cronjob: 0 22 */1 * * /root/simplescripts/mariadb-backup/mariadb-backup.sh
Dependency: mysqldump
Syntax: Variables -> camelCase / Functions -> PascalCase

© Nathanael Liechti

Header

#############################################################################
################################# Variables #################################
#############################################################################

backupDB="eatthis_test"
backupLocation="/root/backup" # create directory beforehand
logFile="/root/backup/mariabd-backup-$(date +%Y-%m-%d).log" # create directory beforehand

#############################################################################
################################ Main Script ################################
#############################################################################

echo "------------------- Backup $(uanme -m) $(date +%Y-%m-%d) $backupDB -------------------" >> $logFile
"mysqldump -u root $backupDB --result-file $backupLocation/$backupDB-$(date +%Y-%m-%d)" >> $logFile
echo "finished backup at $(date +%H:%M)" >> $logFile
