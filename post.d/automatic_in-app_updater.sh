#!/usr/bin/env bash


echo "### Update all the in-app in Nextcloud ###"

docker-compose exec -T --user www-data app php occ app:update --all


