#!/usr/bin/env bash

set -exou pipefail
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
    set -- vsftpd /etc/vsftpd/vsftpd.conf "$@"
fi

_config() {
    # backwards compatibility for default environment variables
    : "${FTP_USER:=${USER:-admin}}"
    : "${FTP_PASS:=${PASS:-$(cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c ${LEN:-16})}}"
    : "${FTP_PASV_ADDRESS:=${PASV_ADDRESS:-$(ip route|awk '/default/ { print $3 }')}}"
    : "${FTP_PASV_MIN_PORT:=${PASV_MIN_PORT:-21100}}"
    : "${FTP_PASV_MAX_PORT:=${PASV_MAX_PORT:-21110}}"

    configEnvKeys=(
        user
        pass
        pasv_address
        pasv_min_port
        pasv_max_port
    )

    for configEnvKey in "${configEnvKeys[@]}"; do file_env "FTP_${configEnvKey^^}"; done

    echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
    db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
    # Get log file path
    FTP_LOG_FILE=`grep vsftpd_log_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`
}

# # allow the container to be started with `--user`
# # if [[ "$1" == vsftpd* ]] && [ "$(id -u)" = '0' ]; then
# if [ "$1" = 'vsftpd' -a "$(id -u)" = '0' ]; then
#     _config
#     # exec gosu `--user` "$BASH_SOURCE" "$@"
#     set -- gosu "$@" vsftpd /etc/vsftpd/vsftpd.conf
# fi

if [ "$1" = 'vsftpd' ]; then
    _config
    cat << EOB
    SERVER SETTINGS
    ---------------
    · FTP User: $FTP_USER
    · FTP Password: $FTP_PASS
    · Log file: $FTP_LOG_FILE
    · Redirect vsftpd log to STDOUT: No.
EOB
    env
    nl  /etc/vsftpd/vsftpd.conf
    set -- "$@" /etc/vsftpd/vsftpd.conf
fi

exec "$@"
