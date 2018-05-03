#!/bin/bash
#
#	ACCOUNT FOLDER & DATABASE BACKUP SCRIPT
#
#	---------------------------------------
#	by gellai.com
#	---------------------------------------
#
#	2017 May
#
#
#
#	IMPORTANT!
#	----------
#	AutoMySQLBackup should run before this script.
#
#
#	ORDER OF BACKUP SCRIPTS IN CRONTAB
#	----------------------------------
#	1. MySQL Auto Backup
#	2. Account Backup (this script)
#	3. FTP Transfer
#
#

#
# The location of the configuration file
#
source /etc/account-backup-cron/account-backup-cron.conf

#################################################
#                                               #
#   DO NOT CHANGE ANYTHING BEYOND THIS POINT    #
#                                               #
#################################################

DAY_OF_WEEK=`date +%a`
DATE_STAMP=`date +%Y-%m-%d`
TIME_STAMP=`date +%H%M%S`
DAY_STAMP=`date +%d`

BACKUP_PATH=${PARENT_DIR}${BACKUP_DIR}

cd /
mkdir -p ${BACKUP_PATH}

#
# Get a list of User Accounts from the database
#
INCLUDES=$(mysql root_cwp -B -N -s -e "SELECT username FROM user")

#
# Backups -> Tar GZip
#
for ITEM in ${INCLUDES}
do
	/bin/mkdir -p ${BACKUP_PATH}/daily/${ITEM}/tmp/
	/bin/mkdir -p ${BACKUP_PATH}/weekly/${ITEM}/
	/bin/mkdir -p ${BACKUP_PATH}/monthly/${ITEM}/

	BACKUP_FILE=backup-${ITEM}-${DATE_STAMP}-${DAY_OF_WEEK}-${TIME_STAMP}.tar.gz

	/usr/bin/rsync -aq /home/${ITEM}/* ${BACKUP_PATH}/daily/${ITEM}/tmp/${ITEM}

	cd ${BACKUP_PATH}/daily/${ITEM}/tmp/

	/bin/tar -czf ${BACKUP_PATH}/daily/${ITEM}/${BACKUP_FILE} ${ITEM} > /dev/null 2>&1
	
	cd ${BACKUP_PATH}/daily/${ITEM}/
	rm -rf tmp/

	ls -t | sed -e '1,'${COUNT_DAILY}'d' | xargs -d '\n' rm > /dev/null 2>&1

	#
	# Weekly Backup
	#
    if [ ${DAY_OF_WEEK} = ${WEEKLY_DAY} ]
	then
		cp ${BACKUP_PATH}/daily/${ITEM}/${BACKUP_FILE} ${BACKUP_PATH}/weekly/${ITEM}/backup-weekly-${ITEM}-${DATE_STAMP}-${DAY_OF_WEEK}-${TIME_STAMP}.tar.gz

        cd ${BACKUP_PATH}/weekly/${ITEM}/

        ls -t | sed -e '1,'${COUNT_WEEKLY}'d' | xargs -d '\n' rm > /dev/null 2>&1
    fi
	
	#
	# Monthly Backup
	#
	if [ ${DAY_STAMP} = ${MONTHLY_DAY} ]
	then
		cp ${BACKUP_PATH}/daily/${ITEM}/${BACKUP_FILE} ${BACKUP_PATH}/monthly/${ITEM}/backup-monthly-${ITEM}-${DATE_STAMP}-${DAY_OF_WEEK}-${TIME_STAMP}.tar.gz

		cd ${BACKUP_PATH}/monthly/${ITEM}/

		ls -t | sed -e '1,'${COUNT_MONTHLY}'d' | xargs -d '\n' rm > /dev/null 2>&1
	fi
done
