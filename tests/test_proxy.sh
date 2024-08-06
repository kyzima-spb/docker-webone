#!/usr/bin/env bash

set -eo pipefail


echo_error() {
    echo -ne >&2 "$*"
}


log() {
    echo_error "[$(date --rfc-3339=seconds)]" "$@"
}


runContainer() {
    local maxWait=${MAX_WAIT:-60}
    local waitInterval=${WAIT_INTERVAL:-5}
    local containerId
    local elapsedTime=0

    log "Start container with arguments $*: "
    containerId=$(docker run --rm -d -p '8080:8080' "$@") || exit 1
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
        esac || exit 1
    done

    echo_error 'FAIL\n'

    return 1
}


testResponseCode() {
    local url="$1"
    local expected=${2:-200}
    local result

    result=$(curl -x http://127.0.0.1:8080 -L -o /dev/null -s -w '%{http_code}' "$url" || exit 0)

    if [[ "$result" == "$expected" ]]; then
        log "test_response_code[$url]: OK\n"
    else
        log "test_response_code[$url]: FAIL ($expected, got $result)\n"
        exit 1
    fi
}


testResponse() {
    local url="$1"
    local expected="$2"
    local result

    result=$(curl -x http://127.0.0.1:8080 -L -s "$url" | grep -o "$expected" || exit 0)

    if [[ -z "$result" ]]; then
        log "test_response[$url]: FAIL ($result not match pattern $expected)\n"
        exit 1
    else
        log "test_response[$url]: OK\n"
    fi
}


containerId="$(runContainer "$@")"
trap 'docker stop "$containerId" > /dev/null' EXIT

testResponseCode 'http://google.com'
testResponseCode 'http://api.github.com/user' 401

testResponse 'http://narod.ru' 'http://web.archive.org'
testResponse 'http://glukoza.ru' 'http://web.archive.org'
testResponse 'http://nnz-home.ru' 'NNZ-Home'
testResponse 'http://127.0.0.1:8080' 'Internal URLs'
