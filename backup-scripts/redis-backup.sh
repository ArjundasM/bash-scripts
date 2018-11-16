#!/bin/bash
#MAINTAINER: arjundasm
#PURPOSE: BACKUP REDIS DATABASE AND TO UPLOAD TO S3
#install rdiff-backup: apt install rdiff-backup

LOG_DIR="/home/ubuntu/backup/logs"
LOG_FILE="redis-backup.log"
TSTAMP=$(date +"%d-%b-%Y:%H-%M-%S")
BACKUP_DIR="/home/ubuntu/backup/redis"
S3_BUCKET="s3://database-backup/redis"

mkdir -p $LOG_DIR

echo "$TSTAMP: Starting backup" >> "$LOG_DIR/$LOG_FILE"
        sudo rdiff-backup --preserve-numerical-ids /var/lib/redis $BACKUP_DIR/$TSTAMP
	echo "$TSTAMP: Backup of database done successfully" >> "$LOG_DIR/$LOG_FILE"

#Deleting files older than 2days from local machine
find  $BACKUP_DIR/* -mtime +2   -exec rm  {}  \;
echo "$TSTAMP: Deleted files with more than 2 days of age" >> "$LOG_DIR/$LOG_FILE"

#Uploading files to s3
echo "$TSTAMP: Files upload to s3 started" >> "$LOG_DIR/$LOG_FILE"
s3cmd put --recursive $BACKUP_DIR/$TSTAMP/* $S3_BUCKET/$TSTAMP/
echo "$TSTAMP: Files are uploaded successfully" >> "$LOG_DIR/$LOG_FILE"