#!/usr/bin/env bash


echo "### Maintain DB Schemes ###"

docker-compose exec -T --user www-data app php occ db:add-missing-indices
docker-compose exec -T --user www-data app php occ db:add-missing-columns


