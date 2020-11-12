#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

# Everytime mariadb (mysql) gets updated/upgraded you need the run the command mysql_upgrade, so
# that is what happens here.
#
# NOTE: The command uses some shell magic there uses the value of the internal
# variable MYSQL_ROOT_PASSWORD as the password
docker-compose exec -T --user mysql db sh -c 'mysql_upgrade -u root "-p${MYSQL_ROOT_PASSWORD}" || true'

