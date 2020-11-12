#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab:

set -eu

if [ ! -d .git ]; then
    echo The working directory have to the root directory of the git project
    exit 1
fi

export DOCKER_COMPOSE_FILE="docker-compose.yml"

### Config Variables
CURL_MAX_TIME=30


### Global Variables
RUN=1
FIRST=0
FAIL_COUNT=0


_stop() {
    RUN=0
}
trap _stop SIGINT 


post_nextcloud() {
    dir="post.d"
    if [ -d "${dir}" ]; then
        echo "### Run Post Nextcloud scripts (${dir}) ###"
    else
        echo "### CAN'T run post Nextcloud scripts, because the folder (${dir}) is missing ###"
    fi

    for file in "${dir}/"*.sh; do
        if [ -x "${file}" ]; then
          echo "## Running the post-script: $(basename "${file}")"
            if "${file}"; then
                echo "# The post-script succeeded: $(basename "${file}")"
            else
                echo "# The post-script FAILED:    $(basename "${file}")"
            fi
        fi
    done
}


/usr/bin/docker-compose -f "${DOCKER_COMPOSE_FILE}" up -d --build


[ -n "${NOTIFY_SOCKET:-}" ] && systemd-notify --status="Waiting for Nextcloud to be ready"
while [ ${RUN} -eq 1 ]; do
    res=$(curl --max-time ${CURL_MAX_TIME} -s -w "\n%{http_code}\n" 'https://nextcloud.best.aau.dk/status.php' || true)
    line_count=$(wc -l <<< ${res})
    body=$(head -n $(expr ${line_count} - 1) <<< ${res})
    http_code=$(tail -n 1 <<< ${res})

    if [ "${http_code}" = "200" ]; then
        if [ "$(jq ".maintenance" <<< ${body})" = "false" ]; then
            if [ "$(jq ".installed" <<< ${body})" = "true" ]; then
                if [ ${FIRST} -eq 0 ]; then
                    FIRST=1
                    [ -n "${NOTIFY_SOCKET:-}" ] && systemd-notify \
                        --status="Nextcloud should be ready, but lets wait 60secs before announcing it"
                    sleep 60
                    [ -n "${NOTIFY_SOCKET:-}" ] && systemd-notify \
                        --status="Run Post Nextcloud scripts"
                    post_nextcloud
                fi
                [ -n "${NOTIFY_SOCKET:-}" ] && systemd-notify --ready \
                    --status="Nextcloud is ready"
            fi
        fi

    elif [ "${http_code}" = "000" ] && [ ${FIRST} -eq 1 ]; then
        if [ ${FAIL_COUNT} -le 4 ]; then
            FAIL_COUNT=$(expr $FAIL_COUNT + 1)
            [ -n "${NOTIFY_SOCKET:-}" ] && systemd-notify \
                --status="Nextcloud is still considered to be working, but ${FAIL_COUNT} failed healt check have happened"
        else
            [ -n "${NOTIFY_SOCKET:-}" ] && systemd-notify \
                --status="Something when wrong and the service is not running as it is suppose to"
            echo "Something when wrong and the service is not running as it is suppose to"
            exit 1
        fi
    fi

    sleep 10
done


