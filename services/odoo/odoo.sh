#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

ODOO_BUILD_PATH=/build/services/odoo

curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
echo 'deb https://deb.nodesource.com/node_8.x xenial main' > /etc/apt/sources.list.d/nodesource.list
echo 'deb-src https://deb.nodesource.com/node_8.x xenial main' >> /etc/apt/sources.list.d/nodesource.list

apt-get update

## Install Odoo Server
apt-get install -y --no-install-recommends \
build-essential \
git \
nodejs \
postgresql-client \
python3 \
python3-pip \
python3-renderpm \
python3-setuptools \
python3-wheel \
python3-watchdog \
xz-utils \
iproute2 \
libpython3-dev \
libsasl2-dev \
libldap2-dev \
uuid-runtime 

npm install -g rtlcss 

wget -nv https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
dpkg --force-depends -i wkhtmltox_0.12.5-1.xenial_amd64.deb
apt-get install -y -f --no-install-recommends
rm -rf wkhtmltox_0.12.5-1.xenial_amd64.deb
ln -s /usr/local/bin/wkhtmltopdf /usr/bin
ln -s /usr/local/bin/wkhtmltoimage /usr/bin

pip3 install num2words xlwt

adduser --system --home=/opt/odoo --group odoo

mkdir -p /opt
cd /opt

#git config --global http.proxy ${HTTP_PROXY}
#git config --global https.proxy ${HTTP_PROXY}
git clone https://www.github.com/odoo/odoo --depth 1 --branch 12.0 --single-branch odoo
pip3 install -r /opt/odoo/doc/requirements.txt
pip3 install -r /opt/odoo/requirements.txt
pip3 install odoorpc

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
libpython3-dev \
libsasl2-dev \
libldap2-dev

rm -rf /root/.cache
rm -rf /opt/odoo/.github
rm -rf /opt/odoo/.tx
rm -rf /opt/odoo/.git
rm -rf /opt/odoo/doc
rm -rf /opt/odoo/setup
rm -rf /opt/odoo/debian
