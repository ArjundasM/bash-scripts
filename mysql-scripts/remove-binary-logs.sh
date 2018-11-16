#!/bin/bash
#SCRIPT TO REMOVE BINARY LOGS 

mysql_username=root
mysql_password='root'
key_file="/home/ubuntu/.ssh/id_rsa"
user_name=ubuntu
ip=1.2.3.4
LOG_FILE="/home/ubuntu/backup/logs"
TSTAMP=$(date +"%d-%b-%Y:%H-%M-%S")

echo "$TSTAMP: Removing mysql binary logs" >> "$LOG_FILE/binary-remove.log"
ssh -i $key_file $user_name@$ip "sudo cp /var/lib/mysql/master.info /tmp && chown ubuntu:ubuntu /tmp/master.info"
scp -i $key_file $user_name@$ip:/tmp/master.info /tmp
echo "$TSTAMP: master.info file copied successfully from slave machine" >> "$LOG_FILE/binary-remove.log"

#enter file location of mysql info
file="/tmp/master.info"
#get the exact word
word="$(cat $file | grep mysql-bin)"
#value for substitution
reduce=2

#get number of letters in the searching word 
number="$(($(echo $word | wc -c)-1))"

#get the last two digits of the string [it must be integer]
last_digit="$(echo $word | tail -c 3)"

#get the word-$reduce
string1="$(echo $word | cut -c1-$(($number-2)))"

#reduce $reduce from $last_digit
value=$(($last_digit-$reduce))
string2=$(printf "%02d" $value)

#Combine string1 and string2
final=$string1$string2

#execute mysql command to remove binary logs
mysql -u $mysql_username -p$mysql_password -e "purge binary logs to '$final'";
echo "$TSTAMP: Successfully removed binary logs" >> "$LOG_FILE/binary-remove.log"
