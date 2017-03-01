#!/bin/bash

set -e

if [ "${DEBUG}" = true ]; then
  set -x
fi

DISABLE_ODOO=${DISABLE_ODOO:-0}

if [ ! "${DISABLE_ODOO}" -eq 0 ]; then
  touch /etc/service/odoo/down
else
  rm -f /etc/service/odoo/down
fi

POSTGRESQL_HOST=${POSTGRESQL_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
if [ ${POSTGRESQL_PORT} =~ ^[-0-9]+$ ]; then
  POSTGRESQL_PORT=${POSTGRESQL_PORT}
else
  POSTGRESQL_PORT=${POSTGRESQL_PORT_5432_TCP_PORT}
fi

POSTGRESQL_USER=${POSTGRESQL_USER:-${POSTGRESQL_ENV_POSTGRESQL_USERNAME}}
POSTGRESQL_PASS=${POSTGRESQL_PASS:-${POSTGRESQL_ENV_POSTGRESQL_PASSWORD}}

ODOO_SMTP_HOST=${ODOO_SMTP_HOST:-172.17.0.1}
ODOO_SMTP_PORT=${ODOO_SMTP_PORT:-25}

if [ ! -f "/etc/odoo/odoo-server.conf" ]; then
  cp /config/etc/odoo/odoo-server.conf /etc/odoo/odoo-server.conf

  sed -e "s/db_host = .*/db_host = ${POSTGRESQL_HOST}/g" -i /etc/odoo/odoo-server.conf
  sed -e "s/db_port = .*/db_port = ${POSTGRESQL_PORT}/" -i /etc/odoo/odoo-server.conf
  sed -e "s/db_user = .*/db_user = ${POSTGRESQL_USER}/g" -i /etc/odoo/odoo-server.conf
  sed -e "s/db_password = .*/db_password = ${POSTGRESQL_PASS}/g" -i /etc/odoo/odoo-server.conf

  sed -e "s/smtp_server = .*/smtp_server = ${ODOO_SMTP_HOST}/g" -i /etc/odoo/odoo-server.conf
  sed -e "s/smtp_port = .*/smtp_port = ${ODOO_SMTP_PORT}/g" -i /etc/odoo/odoo-server.conf
fi

UUID=`uuidgen`
ODOO_SUPER_PASSWORD=${ODOO_SUPER_PASSWORD:-${UUID}}
export ODOO_SUPER_PASSWORD
sed -e "s/admin_passwd = .*/admin_passwd = ${ODOO_SUPER_PASSWORD}/g" -i /etc/odoo/odoo-server.conf

chown odoo:root /etc/odoo/odoo-server.conf
chmod 640 /etc/odoo/odoo-server.conf

chown -R odoo:odoo /opt/odoo/
chown -R odoo:odoo /var/lib/odoo/
chown -R odoo:odoo /var/log/odoo

if [ "${DISABLE_ODOO}" -eq 0 ]; then

  touch /var/log/odoo/odoo-server.log
  cat /dev/null > /var/log/odoo/odoo-server.log
  chown -R odoo:odoo /var/log/odoo

  function waitAandInitializeOdoo()
  {
    echo "Waiting for Odoo Server to come up ..."

    while read LINE; \
    do \
      if [[ $LINE =~ .*HTTP\ service\ \(werkzeug\)\ running\ on.* ]]; then \
        echo "Odoo Server is up"; \
        break; \
      fi \
    done < <(tail -f /var/log/odoo/odoo-server.log)

    sleep 3
    echo "Configuring Odoo ...."
    /opt/odoo/odoo-bootstrap.py
    echo "Configuring Done"
    exit 0
  }

  sleep 2
  # Background the function call
  waitAandInitializeOdoo &

fi
