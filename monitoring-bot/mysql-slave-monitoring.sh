#!/bin/sh
#
# Set the maximum number of seconds behind master that will be ignored. 
# If the slave is be more than maximumSecondsBehind, an email will be sent. 
#
BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN
GROUP_ID=YOUR_TELEGRAM_GROUP_ID
maximumSecondsBehind=300
database="YOUR_DB_NAME"
user="DB_USER"
password="DB_PASSWORD"
tmpFile="/tmp/replicationStatus_$database.txt"
mysqlSockFile="/var/lib/mysql/mysql.sock"

function send_telegram(){
    DATA='{"chat_id": '$GROUP_ID', "text": "'$MESSAGE'", "disable_notification": false, "parse_mode": "html", "disable_web_page_preview": true}'
    curl -X POST \
     -H 'Content-Type: application/json' \
     -d "$DATA" \
     https://api.telegram.org/bot$BOT_TOKEN/sendMessage
}

#
# Checking MySQL replication status...
#
mysql -u$user -p"$password" --socket=$mysqlSockFile -e 'SHOW SLAVE STATUS \G' | grep 'Running:\|Master:\|Error:' > $tmpFile

#
# displaying results, just in case you want to see them 
#
echo "Results:"
cat $tmpFile


#
# checking parameters
#
slaveRunning="$(cat $tmpFile | grep "Slave_IO_Running: Yes" | wc -l)"
slaveSQLRunning="$(cat $tmpFile | grep "Slave_SQL_Running: Yes" | wc -l)"
secondsBehind="$(cat $tmpFile | grep "Seconds_Behind_Master" | tr -dc '0-9')"


#
# Sending email if needed
#
if [[ $slaveRunning != 1 || $slaveSQLRunning != 1 || $secondsBehind -gt $maximumSecondsBehind ]]; then
  echo ""
  echo "Sending an alert"
  MESSAGE="$database - replication issue found"
  send_telegram
  #mail -s "MyServer.com - replication issue found" my@email.com < $tmpFile 
else
  echo ""
  echo "Replication looks fine."
fi