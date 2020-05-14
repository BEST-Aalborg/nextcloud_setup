#!/usr/bin/env bash

set -eu


RUN=1
FIRST=0
FAIL_COUNT=0


_stop() {
	RUN=0
}
trap _stop SIGINT 


post_nextcloud() {
	dir="$(dirname "${0}")/nextcloud_post.d"

	echo "### Run Post Nextcloud scripts (${dir}) ###"

	for file in "${dir}/"*.sh; do
	    if [ -x "${file}" ]; then
	        "${file}"
	    fi
	done
}


/usr/bin/docker-compose -f ${HOME}/nextcloud/docker-compose.yml up --build &


systemd-notify --status="Waiting for Nextcloud to be ready"
while [ ${RUN} -eq 1 ]; do
	res=$(curl --max-time 5 -s -w "\n%{http_code}\n" 'https://nextcloud.best.aau.dk/status.php' || true)
	line_count=$(wc -l <<< ${res})
	body=$(head -n $(expr ${line_count} - 1) <<< ${res})
	http_code=$(tail -n 1 <<< ${res})

	if [ "${http_code}" = "200" ]; then
		if [ "$(jq ".maintenance" <<< ${body})" = "false" ]; then
			if [ "$(jq ".installed" <<< ${body})" = "true" ]; then
				if [ ${FIRST} -eq 0 ]; then
					FIRST=1
					systemd-notify --status="Nextcloud should be ready, but lets wait 60secs before announcing it"
					sleep 60
					systemd-notify --status="Run Post Nextcloud scripts"
					post_nextcloud
				fi
				systemd-notify --ready --status="Nextcloud is ready"
			fi
		fi

	elif [ "${http_code}" = "000" ] && [ ${FIRST} -eq 1 ]; then
		if [ ${FAIL_COUNT} -le 4 ]; then
			FAIL_COUNT=$(expr $FAIL_COUNT + 1)
			systemd-notify --status="Nextcloud is still considered to be working, but ${FAIL_COUNT} failed healt check have happened"
		else
			systemd-notify --status="Something when wrong and the service is not running as it is suppose to"
			echo "Something when wrong and the service is not running as it is suppose to"
			exit 1
		fi
	fi

	sleep 1
done


