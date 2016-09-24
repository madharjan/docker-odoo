#!/bin/bash

set -x

./clean.sh

sudo mkdir -p /opt/docker/odoo/postgresql/etc/
sudo mkdir -p /opt/docker/odoo/postgresql/lib/
sudo mkdir -p /opt/docker/odoo/postgresql/log/

docker run -d -t \
  -e DEBUG=true \
  -e POSTGRESQL_USERNAME=odoo \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  -v /opt/docker/odoo/postgresql/etc:/etc/postgresql/9.3/main \
  -v /opt/docker/odoo/postgresql/lib:/var/lib/postgresql/9.3/main \
  -v /opt/docker/odoo/postgresql/log:/var/log/postgresql \
  --name odoo-postgresql \
  madharjan/docker-postgresql:9.3

sleep 5
docker logs odoo-postgresql

sudo mkdir -p /opt/docker/odoo/etc/
sudo mkdir -p /opt/docker/odoo/addons/
sudo mkdir -p /opt/docker/odoo/lib/
sudo mkdir -p /opt/docker/odoo/log/

docker run -d -t \
  -e DEBUG=true \
  --link odoo-postgresql:postgresql \
  -p 8080:8069 \
  -v /opt/docker/odoo/etc:/etc/odoo \
  -v /opt/docker/odoo/addons:/opt/odoo/extra \
  -v /opt/docker/odoo/lib:/var/lib/odoo \
  -v /opt/docker/odoo/log:/var/log/odoo \
  --name odoo \
  madharjan/docker-odoo:9.0

sleep 2
docker logs odoo
