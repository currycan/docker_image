#!/bin/bash

# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER}"
chown -R ftp:ftp /home/vsftpd/

echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
# Get log file path
LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# stdout server info:
if [ $LOG_STDOUT = "true" ]; then
    exec "$@"
else
cat << EOB
    *************************************************
    SERVER SETTINGS
    ---------------
    · FTP User: $FTP_USER
    · FTP Password: $FTP_PASS
    · Log file: $LOG_FILE
    · Redirect vsftpd log to STDOUT: No.
EOB
    exec "$@" 2>&1 | tee $LOG_FILE
