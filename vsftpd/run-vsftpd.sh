#!/usr/bin/env bash

set -eou pipefail
shopt -s nullglob

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

# if [ "${1:0:1}" = '-' ]; then
if [ "${1#-}" != "$1" ]; then
    set -- "$@" /etc/vsftpd/vsftpd.conf
    echo ">>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<"
    echo "$@"
fi

# allow the container to be started with `--user`
# if [[ "$1" == vsftpd* ]] && [ "$(id -u)" = '0' ]; then
if [ "$1" = 'vsftpd' -a "$(id -u)" = '0' ]; then
    # Change the ownership of user-mutable directories to `--user`
    for path in \
        /home/vsftpd/${FTP_USER} \
        /var/log/vsftpd \
        /etc/vsftpd/ \
    ; do
        chown -R vsftpd:vsftpd "$path"
    done
    # exec gosu `--user` "$BASH_SOURCE" "$@"
    set -- gosu "$@" vsftpd /etc/vsftpd/vsftpd.conf
fi

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
# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER}"

echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
# Get log file path
LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# set -- gosu vsftpd /etc/vsftpd/vsftpd.conf "$@"

exec "$@"
