# docker-odoo

[![Build Status](https://travis-ci.com/madharjan/docker-odoo.svg?branch=master)](https://travis-ci.com/madharjan/docker-odoo)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-odoo.svg)](http://microbadger.com/images/madharjan/docker-odoo)

Docker container for Odoo Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to set database setting or link to postgresql container
* Environment variables to set admin password and company name
* Environment variables to install or uninstall modules on startup
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases
  
## Odoo Server 12.0 (docker-odoo)

| Variable               | Default                | Example          |
|------------------------|------------------------|------------------|
| DISABLE_ODOO           | 0                      | 1 (to disable)   |
| ODOO_DATABASE_NAME     | odoo                   |                  |
| ODOO_ADMIN_PASSWORD    |                        |                  |
| ODOO_ADMIN_EMAIL       |                        |                  |
| ODOO_COMPANY_NAME      | Acme Pte Ltd           |                  |
| ODOO_LANG              | en_US                  |                  |
| ODOO_INSTALL_MODULES   | website                | website,blog     |
| ODOO_UNINSTALL_MODULES |                        |                  |
| ODOO_SMTP_HOST         | [ default gateway ip ] |                  |
| ODOO_SMTP_PORT         | 25                     |                  |
| POSTGRESQL_HOST        | linked to 'postgresql' | 172.17.0.1       |
| POSTGRESQL_PORT        | linked to 'postgresql' | 5432             |
| POSTGRESQL_USER        | linked to 'postgresql' | odoo             |
| POSTGRESQL_PASS        | linked to 'postgresql' | pass             |

## Build

```bash
# clone project
git clone https://github.com/madharjan/docker-odoo
cd docker-odoo

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

**Note**: update environment variables below as necessary

```bash
# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/odoo/postgresql/etc/
sudo mkdir -p /opt/docker/odoo/postgresql/lib/
sudo mkdir -p /opt/docker/odoo/postgresql/log/

# stop & remove previous instances
docker stop odoo-postgresql
docker rm odoo-postgresql

# run container
docker run -d \
  -e POSTGRESQL_USERNAME=odoo \
  -e POSTGRESQL_PASSWORD=odoo \
  -v /opt/docker/odoo/postgresql/etc:/etc/postgresql/9.5/main \
  -v /opt/docker/odoo/postgresql/lib:/var/lib/postgresql/9.5/main \
  -v /opt/docker/odoo/postgresql/log:/var/log/postgresql \
  --name odoo-postgresql \
  madharjan/docker-postgresql:9.5

# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/odoo/etc/
sudo mkdir -p /opt/docker/odoo/addons/
sudo mkdir -p /opt/docker/odoo/lib/
sudo mkdir -p /opt/docker/odoo/log/

# stop & remove previous instances
docker stop odoo
docker rm odoo

# run container linked with odoo-postgresql
docker run -d \
  --link odoo-postgresql:postgresql \
  -e ODOO_ADMIN_PASSWORD=Pa55w0rd \
  -e ODOO_ADMIN_EMAIL=admin@local.host \
  -e ODOO_COMPANY_NAME="Acme Pte Ltd" \
  -p 8069:8069 \
  -v /opt/docker/odoo/etc:/etc/odoo \
  -v /opt/docker/odoo/addons:/opt/odoo/extra \
  -v /opt/docker/odoo/lib:/var/lib/odoo \  
  -v /opt/docker/odoo/log:/var/log/odoo \
  --name odoo \
  madharjan/docker-odoo:12.0
```

## Systemd Unit File

**Note**: update environment variables below as necessary

```txt
[Unit]
Description=Odoo Server

After=docker.service

[Service]
TimeoutStartSec=0

ExecStartPre=-/bin/mkdir -p /opt/docker/odoo/etc
ExecStartPre=-/bin/mkdir -p /opt/docker/odoo/addons
ExecStartPre=-/bin/mkdir -p /opt/docker/odoo/lib
ExecStartPre=-/bin/mkdir -p /opt/docker/odoo/log
ExecStartPre=-/usr/bin/docker stop odoo
ExecStartPre=-/usr/bin/docker rm odoo
ExecStartPre=-/usr/bin/docker pull madharjan/docker-odoo:12.0

ExecStart=/usr/bin/docker run \
  --link odoo-postgresql:postgresql \
  -e ODOO_ADMIN_PASSWORD=Pa55w0rd \
  -e ODOO_ADMIN_EMAIL=admin@local.host \
  -e ODOO_COMPANY_NAME="Acme Pte Ltd" \
  -p 8069:8069 \
  -v /opt/docker/odoo/etc:/etc/odoo \
  -v /opt/docker/odoo/addons:/opt/odoo/extra \
  -v /opt/docker/odoo/lib:/var/lib/odoo \  
  -v /opt/docker/odoo/log:/var/log/odoo \
  --name odoo \
  madharjan/docker-odoo:12.0

ExecStop=/usr/bin/docker stop -t 2 odoo

[Install]
WantedBy=multi-user.target
```

## Generate Systemd Unit File

| Variable                 | Default                     | Example                                                          |
|--------------------------|-----------------------------|------------------------------------------------------------------|
| PORT                     |                             | 8069                                                             |
| VOLUME_HOME              | /opt/docker                 | /opt/data                                                        |
| ODOO_DATABASE_NAME       | odoo                        | demo                                                             |
| ODOO_ADMIN_PASSWORD      |                             | Pa55w0rd                                                         |
| ODOO_ADMIN_EMAIL         |                             | root@localhost.localdomain                                       |
| ODOO_COMPANY_NAME        | Acme Pte Ltd                | My Company Pte Ltd                                               |
| ODOO_INSTALL_MODULES     | website                     | website,blogs                                                    |
| ODOO_UNINSTALL_MODULES   |                             |                                                                  |
| ODOO_LANG                | en_US                       | en_UK                                                            |
| LINK_DATABASE_CONTAINER  |                             | postgresql                                                       |

```bash
# generate postgresql.service
docker run --rm \
  -e NAME=postgresql \
  -e POSTGRESQL_PASSWORD=odoo \
  madharjan/docker-postgresql:9.5 \
  postgresql-systemd-unit | \
  sudo tee /etc/systemd/system/postgresql.service

sudo systemctl enable postgresql
sudo systemctl start postgresql

# generate odoo.service
docker run --rm \
  -e PORT=8069 \
  -e LINK_DATABASE_CONTAINER=postgresql \
  -e ODOO_ADMIN_PASSWORD=Pa55w0rd \
  -e ODOO_ADMIN_EMAIL=root@localhost.localdomain \
  -e ODOO_COMPANY_NAME="Acme Pte Ltd" \
  madharjan/docker-odoo:12.0 \
  odoo-systemd-unit | \
  sudo tee /etc/systemd/system/odoo.service

sudo systemctl enable odoo
sudo systemctl start odoo
```
