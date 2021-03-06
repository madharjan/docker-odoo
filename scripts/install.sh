#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

ODOO_CONFIG_PATH=/build/config/odoo

apt-get update

## Install Odoo Server and runit service
/build/services/odoo/odoo.sh

mkdir -p /config/etc/odoo
cp ${ODOO_CONFIG_PATH}/odoo-server.conf /config/etc/odoo/odoo-server.conf

cp /build/services/odoo-bootstrap.py /opt/odoo/

mkdir -p /etc/my_init.d
cp /build/services/20-odoo.sh /etc/my_init.d
chmod 750 /etc/my_init.d/20-odoo.sh

cp /build/bin/odoo-systemd-unit /usr/local/bin
chmod 750 /usr/local/bin/odoo-systemd-unit
