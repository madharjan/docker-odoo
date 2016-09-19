#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "$DEBUG" == true ]; then
  set -x
fi

ODOO_BUILD_PATH=/build/services/odoo

## Install Odoo Server
apt-get install -y --no-install-recommends git nodejs npm python python-pip node-less postgresql-client

adduser --system --home=/opt/odoo --group odoo

mkdir -p /opt
cd /opt

git clone https://www.github.com/odoo/odoo --depth 1 --branch 9.0 --single-branch odoo
#pip install /opt/odoo/doc/requirements.txt
#pip install /opt/odoo/requirements.txt

npm install -g less less-plugin-clean-css

wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
dpkg --force-depends -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
apt-get install -y -f --no-install-recommends
rm -rf wkhtmltox-0.12.1_linux-trusty-amd64.deb

ln -s /usr/local/bin/wkhtmltopdf /usr/bin
ln -s /usr/local/bin/wkhtmltoimage /usr/bin

mkdir -p /etc/odoo
mkdir -p /opt/odoo/addons
mkdir -p /var/log/odoo

cp /opt/odoo/debian/openerp-server.conf /etc/odoo/odoo-server.conf
sed -e 's/addons_path = .*/addons_path = \/opt\/odoo\/addons/g' -i /etc/odoo/odoo-server.conf
sed -e 's/logfile = .*/logfile =  \/var\/log\/odoo\/odoo-server.log/g' -i /etc/odoo/odoo-server.conf

chown -R odoo:odoo /opt/odoo/
chown odoo:root /var/log/odoo
chown odoo: /etc/odoo/odoo-server.conf
chmod 640 /etc/odoo/odoo-server.conf

mkdir -p /etc/service/odoo
cp ${ODOO_BUILD_PATH}/odoo.runit /etc/service/odoo/run
chmod 750 /etc/service/odoo/run

## Configure logrotate
cp /opt/odoo/debian/logrotate /etc/logrotate.d/odoo
