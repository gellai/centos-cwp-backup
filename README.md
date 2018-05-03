# Centos CWP 6.9 Custom Backup

[![N|Gellai](https://www.gellai.com/wp-content/themes/gellai/images/Powered-By-Gellai.png)](https://gellai.com)

## What is this?
This project is a customized backup solution for CentOS Web Panel 6.9 which works with [AutoMySQLBackup](https://sourceforge.net/projects/automysqlbackup) (not included). 


Recommended file locations:

`/etc/account-backup-cron/account-backup-cron.conf`

`/usr/local/bin/account-backup-cron.sh`

`/usr/local/bin/ftp-backup-cron.sh`

## Parameters

`account-backup-cron.conf` configuration guide.

| Parameter | Description | Example Values |
| --------- | ----------- | --------------- |
| PARENT_DIR | Shared parent directory with AutoMySQLBackup but not the same one. Database & user account backups shuld be in separate subdirectories. | /home/backup |
| BACKUP_DIR | Sub directory for user account backups | /account |
| COUNT_DAILY | The number of saved daily backups | 6 |
| WEEKLY_DAY | The day when to do the weekly backup (only 1 day) | Sun |
| COUNT_WEEKLY | The number of saved weekly backups | 2 |
| MONTHLY_DAY | The date of the month when to do the monthly backup (only 1 day) | 01 |
| COUNT_MONTHLY | The number of saved monthly backups | 1 |
| FTP_SERVER | The IPv4 address of the remote FTP server | 111.222.333.444 |
| FTP_PORT | The port number of the remote FTP server | 21 |
| FTP_FOLDER | Remote folder on the FTP server | /centos-cwp |
| FTP_USER | Username to access the FTP server | username |
| FTP_PASS | Password to access the FTP server | password |

[Find out more about this project and setup here.](https://gellai.com)
