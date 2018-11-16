#!/bin/bash
#MAINTAINER: arjundasm
#PURPOSE: BACKUP MONGO DATABASE AND UPLOAD TO S3

#logging
LOG_DIR="/home/ubuntu/backup/logs"
LOG_FILE="mongo-backup.log"
TSTAMP=$(date +"%d-%b-%Y:%H-%M-%S")
BACKUP_DIR="/home/ubuntu/backup/mongo"
S3_BUCKET="s3://database-backup/mongo"

#list of datbases
DB_LIST=(database-a database-b database-c)
mkdir -p $LOG_FILE

echo "$TSTAMP: Starting backup" >> "$LOG_DIR/$LOG_FILE"
for i in ${DB_LIST[@]}; do
        mongodump --db ${i} --out $BACKUP_DIR/$TSTAMP
        echo "$TSTAMP: Backup of database ${i} done successfully" >> "$LOG_DIR/$LOG_FILE"
done
echo "$TSTAMP: All backup are done successfully" >> "$LOG_DIR/$LOG_FILE"

#Deleting files older than 2days from local machine
find  $BACKUP_DIR/* -mtime +2   -exec rm  {}  \;
echo "$TSTAMP: Deleted files with more than 2 days of age" >> "$LOG_DIR/$LOG_FILE"

#Uploading files to s3
echo "$TSTAMP: Files upload to s3 started" >> "$LOG_DIR/$LOG_FILE"
s3cmd put --recursive $BACKUP_DIR/$TSTAMP/* $S3_BUCKET/$TSTAMP/
echo "$TSTAMP: Files are uploaded successfully" >> "$LOG_DIR/$LOG_FILE"