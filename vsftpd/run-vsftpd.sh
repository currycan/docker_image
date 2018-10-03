#!/usr/bin/env bash

set -eu

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

ENV FTP_USER=admin
ENV FTP_PASS=password
ENV FTP_PASV_ADDRESS=127.0.0.1
ENV FTP_PASV_MIN_PORT=21100
ENV FTP_PASV_MAX_PORT=21110
ENV FTP_LOG_STDOUT_FLAG=true

# backwards compatibility for default environment variables
: "${USER:=${FTP_USER:-admin}}"
: "${PASS:=${FTP_PASS:-$(cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16})}}"
: "${ADDRESS:=${FTP_PASV_ADDRESS:-$(ip route|awk '/default/ { print $3 }')}}"
: "${PASV_MIN_PORT:=${FTP_PASV_MIN_PORT:-21100}}"
: "${PASV_MAX_PORT:=${FTP_PASV_MAX_PORT:-21110}}"
: "${LOG_STDOUT:=${FTP_LOG_STDOUT_FLAG:-true}}"

configEnvKeys=(
    user
    pass
    pasv_address
    pasv_max_port
    pasv_min_port
    log_stdout_flag
)

for configEnvKey in "${configEnvKeys[@]}"; do file_env "FTP_${configEnvKey^^}"; done

if [ "${1:0:1}" = '-' ]; then
    set -- /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'vsftpd*' -a "$(id -u)" = '0' ]; then
    # Change the ownership of user-mutable directories to `--user`
    for path in \
        /home/vsftpd/${FTP_USER} \
        /var/log/vsftpd \
    ; do
        chown -R vsftpd:vsftpd "$path"
    done
    # exec gosu `--user` "$BASH_SOURCE" "$@"
    set -- gosu /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf "$@"
fi

# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER}"

echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
# Get log file path
# FTP_PASS=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# # stdout server info:
# if [ $LOG_STDOUT = "true" ]; then
#     exec "$@"

cat << EOB
    *************************************************
    SERVER SETTINGS
    ---------------
    · FTP User: $FTP_USER
    · FTP Password: $FTP_PASS
    · Log file: $LOG_FILE
    · Redirect vsftpd log to STDOUT: No.
EOB
exec "$@"
