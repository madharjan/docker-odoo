#!/bin/bash

set -e

if [ "${DEBUG}" == true ]; then
  set -x
fi

POSTGRESQL_HOST=${POSTGRESQL_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
if ! [ ${POSTGRESQL_PORT} =~ ^[-0-9]+$ ]; then
  POSTGRESQL_PORT=${POSTGRESQL_PORT_5432_TCP_PORT}
fi

POSTGRESQL_USER=${POSTGRESQL_USER:-${POSTGRESQL_ENV_POSTGRESQL_USERNAME}}
POSTGRESQL_PASS=${POSTGRESQL_PASS:-${POSTGRESQL_ENV_POSTGRESQL_PASSWORD}}

sed -e "s/db_host = .*/db_host = ${POSTGRESQL_HOST}/g" -i /etc/odoo/odoo-server.conf
sed -e "s/db_port = .*/db_port = ${POSTGRESQL_PORT}/" -i /etc/odoo/odoo-server.conf
sed -e "s/db_user = .*/db_user = ${POSTGRESQL_USER}/g" -i /etc/odoo/odoo-server.conf
sed -e "s/db_password = .*/db_password = ${POSTGRESQL_PASS}/g" -i /etc/odoo/odoo-server.conf

chown -R odoo:odoo /opt/odoo/
chown -R odoo:odoo /var/lib/odoo/
chown odoo:root /var/log/odoo
chown odoo: /etc/odoo/odoo-server.conf
chmod 640 /etc/odoo/odoo-server.conf
