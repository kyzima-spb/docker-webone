#!/usr/bin/env sh

WEBONE_CONFIG_FILE="webone.conf"
DEFAULT_HOST_NAME=${DEFAULT_HOST_NAME:-''}

if [ -z "$DEFAULT_HOST_NAME" ]; then
    ifaceName="$(ip route | awk '/default/ { print $5 }')"
    defaultHostName="$(ip -o -4 addr show "$ifaceName" | awk '{print $4}' | awk -F'/' '{ print $1 }')"

    echo "* DefaultHostName was determined automatically and is equal to: $defaultHostName"
    sed -ri "s|^DefaultHostName=%HostName%$|DefaultHostName=${defaultHostName}|" "$WEBONE_CONFIG_FILE"
else
    sed -ri "s|^DefaultHostName=.+|DefaultHostName=${DEFAULT_HOST_NAME}|" "$WEBONE_CONFIG_FILE"
fi

exec "$@"
