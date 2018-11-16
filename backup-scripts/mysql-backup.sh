#!/bin/bash

#MAINTAINER: arjundasm
#PURPOSE: BACKUP SCRIPT FOR MYSQL DATABASE AND TO UPLOAD THE FILES TO S3
#USAGE: bash mysql-baskup.sh

LOG_DIR="/home/ubuntu/backup/logs"
LOG_FILE_NAME=mysql-backup.log
TSTAMP=$(date +"%d-%b-%Y:%H-%M-%S")
BACKUP_DIR="/home/ubuntu/backup/mysql"
S3_BUCKET="s3://database-backup/mysql"
DB_PASSWORD='root'
DB_USERNAME=root
LOG_FILE_NAME=mysql-backup.log

#list of databases, defined as array
DB_LIST=(database-a database-b database-c)

#creating log directory
mkdir -p $LOG_DIR

echo "$TSTAMP: Starting mysql backup" >> "$LOG_DIR/$LOG_FILE_NAME"
for i in ${DB_LIST[@]}; do
	mysqldump -u $DB_USERNAME -p$DB_PASSWORD ${i} | gzip > $BACKUP_DIR/$TSTAMP/${i}_$TSTAMP.sql.gz
	echo "$TSTAMP: Backup of database ${i} done successfully" >> "$LOG_DIR/$LOG_FILE_NAME"
done
echo "$TSTAMP: All backup are done successfully" >> "$LOG_DIR/$LOG_FILE_NAME"

#Deleting files older than 2-days from local machine
find  $BACKUP_DIR/* -mtime +2   -exec rm  {}  \;
echo "$TSTAMP: Deleted files with more than 2 days of age" >> "$LOG_DIR/$LOG_FILE_NAME"

#Uploading files to s3
echo "$TSTAMP: Files upload to s3 started" >> "$LOG_DIR/$LOG_FILE_NAME"
s3cmd put --recursive $BACKUP_DIR/$TSTAMP/* $S3_BUCKET/$TSTAMP/
echo "$TSTAMP: Files are uploaded successfully" >> "$LOG_DIR/$LOG_FILE_NAME"