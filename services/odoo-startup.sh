#!/bin/bash

set -e

if [ "$DEBUG" == true ]; then
  set -x
fi

DB_HOST=${DB_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
DB_PORT=${DB_PORT:-${POSTGRESQL_PORT_5432_TCP_PORT}}

DB_USER=${DB_USER:-${POSTGRESQL_ENV_POSTGRES_DB_USERNAME}}
DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_POSTGRES_DB_PASSWORD}}

sed 's/db_host = .*/db_host = ${DB_HOST}' -i /etc/odoo/odoo-server.conf
sed 's/db_port = .*/db_port = ${DB_PORT}' -i /etc/odoo/odoo-server.conf
sed 's/db_user = .*/db_user = ${DB_USER}' -i /etc/odoo/odoo-server.conf
sed 's/db_password = .*/db_password = ${DB_PASS}' -i /etc/odoo/odoo-server.conf
