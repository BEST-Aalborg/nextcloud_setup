#!/usr/bin/env bash


echo "### Update all the in-app in Nextcloud ###"

if [ -z "${DOCKER_COMPOSE_FILE:-}" ]; then
	echo "ERROR: The variable  DOCKER_COMPOSE_FILE was not defined"
	exit 0
fi

docker-compose -f "${DOCKER_COMPOSE_FILE}" exec -T --user www-data app php occ app:update --all


