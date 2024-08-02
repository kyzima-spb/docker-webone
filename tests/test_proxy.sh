#!/usr/bin/env bash

set -eo pipefail


echo_error() {
    echo -ne >&2 "$*"
}


log() {
    echo_error "[$(date --rfc-3339=seconds)]" "$@"
}


runContainer() {
    local imageName="${1:-webone}"
    local maxWait=${2:-60}
    local waitInterval=${3:-5}
    local containerId
    local elapsedTime=0

    log 'Start container: '
    containerId=$(docker run --rm -d -p '8080:8080' "$imageName") || exit 1
    echo_error 'OK\n'

    log 'Container health: '

    until [[ "$elapsedTime" -ge "$maxWait" ]]; do
        case $(docker inspect --format='{{.State.Health.Status}}' "$containerId") in
            healthy)
                echo "$containerId"
                echo_error 'OK\n'
                return 0
                ;;
            *)
                sleep "$waitInterval"
                elapsedTime=$((elapsedTime + waitInterval))
                ;;
        esac|| exit 1
    done

    echo_error 'FAIL\n'

    return 1
}


testProxy() {
    local url="$1"
    local expected=${2:-200}
    local result

    result=$(curl -x http://127.0.0.1:8080 -L -o /dev/null -s -w '%{http_code}' "$url" || exit 0)

    if [[ "$result" == "$expected" ]]; then
        log "test_proxy[$url]: OK\n"
    else
        log "test_proxy[$url]: FAIL ($expected, got $result)\n"
        exit 1
    fi
}


containerId="$(runContainer "$1")"
trap 'docker stop "$containerId" > /dev/null' EXIT

testProxy http://google.com
testProxy http://narod.ru
testProxy http://google.com/404 404
testProxy http://api.github.com/user 401
