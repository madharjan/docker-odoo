#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" == true ]; then
  set -x
fi

ODOO_BUILD_PATH=/build/services/odoo

## Install Odoo Server
apt-get install -y --no-install-recommends \
build-essential \
fontconfig \
git \
libevent-dev \
libfreetype6-dev \
libjpeg8-dev \
libjpeg-dev \
liblcms2-dev \
liblcms2-utils \
libldap2-dev \
libpq-dev \
libpython-dev \
libsasl2-dev \
libtiff5-dev \
libwebp-dev \
libxml2-dev \
libxslt1-dev \
libxslt1-dev \
libyaml-dev \
nodejs \
node-less \
npm \
pkg-config \
postgresql-client \
python \
python-pip \
python-tk \
tcl8.6-dev \
tk8.6-dev \
zlib1g-dev \
uuid-runtime

adduser --system --home=/opt/odoo --group odoo

mkdir -p /opt
cd /opt

git clone https://www.github.com/odoo/odoo --depth 1 --branch 9.0 --single-branch odoo
pip install -r /opt/odoo/doc/requirements.txt
pip install -r /opt/odoo/requirements.txt
pip install odoorpc

npm install -g less less-plugin-clean-css

wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
dpkg --force-depends -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
apt-get install -y -f --no-install-recommends
rm -rf wkhtmltox-0.12.1_linux-trusty-amd64.deb

ln -s /usr/local/bin/wkhtmltopdf /usr/bin
ln -s /usr/local/bin/wkhtmltoimage /usr/bin

ln -s /usr/bin/nodejs /usr/bin/node

mkdir -p /etc/odoo
mkdir -p /opt/odoo/extra
mkdir -p /var/lib/odoo
mkdir -p /var/log/odoo

mkdir -p /etc/service/odoo
cp ${ODOO_BUILD_PATH}/odoo.runit /etc/service/odoo/run
chmod 750 /etc/service/odoo/run

## Configure logrotate
cp /opt/odoo/debian/logrotate /etc/logrotate.d/odoo


## Clean up
apt-get remove -y \
libevent-dev \
libfreetype6-dev \
libjpeg8-dev \
libjpeg-dev \
liblcms2-dev \
libldap2-dev \
libpq-dev \
libpython-dev \
libsasl2-dev \
libtiff5-dev \
libwebp-dev \
libxml2-dev \
libxslt1-dev \
libxslt1-dev \
libyaml-dev \
