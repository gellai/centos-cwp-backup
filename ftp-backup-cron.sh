#!/bin/bash
#
#	BACKUP TO REMOTE FTP LOCATION
#
#	-----------------------------
#	by gellai.com
#	-----------------------------
#
#	2017 May
#
#

#
# The location of the configuration file
#
source /etc/account-backup-cron/account-backup-cron.conf

#
# The folder which will be mounted as FTP location 
#
MOUNTING_FOLDER=/mnt/ftp

#################################################
#                                               #
#   DO NOT CHANGE ANYTHING BEYOUND THIS POINT   #
#                                               #
#################################################

INCLUDES=$(mysql root_cwp -B -N -s -e "SELECT username FROM user")

rm -rf ${MOUNTING_FOLDER}

mkdir -p ${MOUNTING_FOLDER}

curlftpfs -o allow_other ftp://${FTP_USER}:${FTP_PASS}@${FTP_SERVER}:${FTP_PORT}${FTP_FOLDER} ${MOUNTING_FOLDER}

rsync -avz ${PARENT_DIR}/* ${MOUNTING_FOLDER}

#
#	Syncronize the number of Account backups on the FTP server
#	according to the settings in account-backup-cron.conf.
#	Expired files will be deleted.
#
for ITEM in ${INCLUDES}
do
	cd ${MOUNTING_FOLDER}/account/daily/${ITEM}/

	ls -t | sed -e '1,'${COUNT_DAILY}'d' | xargs -d '\n' rm > /dev/null 2>&1

	cd ${MOUNTING_FOLDER}/account/weekly/${ITEM}/

	ls -t | sed -e '1,'${COUNT_WEEKLY}'d' | xargs -d '\n' rm > /dev/null 2>&1

	cd ${MOUNTING_FOLDER}/account/monthly/${ITEM}/

	ls -t | sed -e '1,'${COUNT_MONTHLY}'d' | xargs -d '\n' rm > /dev/null 2>&1
done


#
# 	Get databases from MySQL
# 	Use AutoMySQLBackup's config file
#
source /etc/automysqlbackup/automysqlbackup.conf

mapfile -t alldbnames < <(mysql --user="${CONFIG_mysql_dump_username}" --password="${CONFIG_mysql_dump_password}" --host="${CONFIG_mysql_dump_host}" --skip-column-names --batch -e "show databases")

#
# 	Remove excluded database names from the list
#	configured in AutoMySQLBackup's config file
#
for exclude in "${CONFIG_db_exclude[@]}"
do
	for i in "${!alldbnames[@]}"
	do
		if [[ "x${alldbnames[$i]}" = "x${exclude}" ]]
		then
			unset 'alldbnames[i]'
		fi
	done
done

#
#	Syncronize the number of Database backups on the FTP server
#	according to the settings in account-backup-cron.conf.
#	Expired files will be deleted.
#
for s in "${!alldbnames[@]}"
do
	cd ${MOUNTING_FOLDER}/db/daily/${alldbnames[$s]}/ > /dev/null 2>&1

	ls -t | sed -e '1,'${COUNT_DAILY}'d' | xargs -d '\n' rm > /dev/null 2>&1

	cd ${MOUNTING_FOLDER}/db/weekly/${alldbnames[$s]}/ > /dev/null 2>&1

	ls -t | sed -e '1,'${COUNT_WEEKLY}'d' | xargs -d '\n' rm > /dev/null 2>&1

	cd ${MOUNTING_FOLDER}/db/monthly/${alldbnames[$s]}/ > /dev/null 2>&1

	ls -t | sed -e '1,'${COUNT_MONTHLY}'d' | xargs -d '\n' rm > /dev/null 2>&1
done

#
# Miscellinous folders created by AutoMySQLBackup script
#
cd ${MOUNTING_FOLDER}/db/fullschema/

ls -t | sed -e '1,'${COUNT_DAILY}'d' | xargs -d '\n' rm > /dev/null 2>&1

cd ${MOUNTING_FOLDER}/db/latest/

ls -t | sed -e '1,'${COUNT_DAILY}'d' | xargs -d '\n' rm > /dev/null 2>&1

cd ${MOUNTING_FOLDER}/db/status/

ls -t | sed -e '1,'${COUNT_DAILY}'d' | xargs -d '\n' rm > /dev/null 2>&1

cd ${MOUNTING_FOLDER}/db/tmp/

ls -t | sed -e '1,'${COUNT_DAILY}'d' | xargs -d '\n' rm > /dev/null 2>&1

cd /

umount /mnt/ftp

rm -rf /mnt/ftp/
