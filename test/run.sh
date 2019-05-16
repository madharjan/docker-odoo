#!/bin/bash

set -x

./clean.sh

sudo mkdir -p /opt/docker/odoo/postgresql/etc/
sudo mkdir -p /opt/docker/odoo/postgresql/lib/
sudo mkdir -p /opt/docker/odoo/postgresql/log/

docker run -d -t \
  -e DEBUG=false \
  -e POSTGRESQL_USERNAME=odoo \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  -v /opt/docker/odoo/postgresql/etc:/etc/postgresql/9.5/main \
  -v /opt/docker/odoo/postgresql/lib:/var/lib/postgresql/9.5/main \
  -v /opt/docker/odoo/postgresql/log:/var/log/postgresql \
  --name odoo-postgresql \
  madharjan/docker-postgresql:9.5

sleep 5
#docker logs odoo-postgresql

sudo mkdir -p /opt/docker/odoo/etc/
sudo mkdir -p /opt/docker/odoo/addons/
sudo mkdir -p /opt/docker/odoo/lib/
sudo mkdir -p /opt/docker/odoo/log/

docker run -d -t \
  -e DEBUG=true \
  --link odoo-postgresql:postgresql \
  -e ODOO_ADMIN_PASSWORD=Pa55w0rd \
  -e ODOO_ADMIN_EMAIL=admin@local.host \
  -p 8080:8069 \
  -v /opt/docker/odoo/etc:/etc/odoo \
  -v /opt/docker/odoo/addons:/opt/odoo/extra \
  -v /opt/docker/odoo/lib:/var/lib/odoo \
  -v /opt/docker/odoo/log:/var/log/odoo \
  --name odoo \
  madharjan/docker-odoo:12.0

sleep 5
docker logs -f odoo
