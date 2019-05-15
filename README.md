# docker-odoo

[![Build Status](https://travis-ci.com/madharjan/docker-odoo.svg?branch=master)](https://travis-ci.com/madharjan/docker-odoo)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-odoo.svg)](http://microbadger.com/images/madharjan/docker-odoo)

Docker container for Odoo Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to set database setting or link to postgresql container
* Environment variables to set admin password and company name
* Environment variables to install or uninstall modules on startup
* Bats ([bats-core/bats-core](https://github.com/bats-core/bats-core)) based test cases
  
## Odoo Server 12.0 (docker-odoo)

| Variable               | Default                | Example          |
|------------------------|------------------------|------------------|
| DISABLE_ODOO           | 0                      | 1 (to disable)   |
| ODOO_DATABASE_NAME     | demo                   |                  |
| ODOO_ADMIN_PASSWORD    | password               |                  |
| ODOO_ADMIN_EMAIL       | root@local.host        |                  |
| ODOO_COMPANY           | Demo                   |                  |
| ODOO_LANG              | en_US                  |                  |
| ODOO_INSTALL_MODULES   |                        | website          |
| ODOO_UNINSTALL_MODULES |                        |                  |
| ODOO_SMTP_HOST         | 172.17.0.1             |                  |
| ODOO_SMTP_PORT         | 25                     |                  |
| POSTGRESQL_HOST        | linked to 'postgresql' | 172.17.0.2       |
| POSTGRESQL_PORT        | linked to 'postgresql' | 5432             |
| POSTGRESQL_USER        | linked to 'postgresql' | odoo             |
| POSTGRESQL_PASS        | linked to 'postgresql' | pass              |

## Build

### Clone this project

```bash
git clone https://github.com/madharjan/docker-odoo
cd docker-odoo
```

### Build Containers

```bash
# login to DockerHub
docker login

# build
make

# tests
make run
make tests
make clean

# tag
make tag_latest

# release
make release
```

### Tag and Commit to Git

```bash
git tag 12.0
git push origin 12.0
```

## Run Container

### Prepare folder on host for container volumes

```bash
sudo mkdir -p /opt/docker/odoo/postgresql/etc/
sudo mkdir -p /opt/docker/odoo/postgresql/lib/
sudo mkdir -p /opt/docker/odoo/postgresql/log/
```

### Run `docker-postgresql`

```bash
docker stop odoo-postgresql
docker rm odoo-postgresql

docker run -d \
  -e POSTGRESQL_USERNAME=odoo \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  -v /opt/docker/odoo/postgresql/etc:/etc/postgresql/9.5/main \
  -v /opt/docker/odoo/postgresql/lib:/var/lib/postgresql/9.5/main \
  -v /opt/docker/odoo/postgresql/log:/var/log/postgresql \
  --name odoo-postgresql \
  madharjan/docker-postgresql:9.5
```

### Prepare folder on host for container volumes

```bash
sudo mkdir -p /opt/docker/odoo/etc/
sudo mkdir -p /opt/docker/odoo/addons/
sudo mkdir -p /opt/docker/odoo/lib/
sudo mkdir -p /opt/docker/odoo/log/
```

### Run `docker-odoo` linked with `docker-postgresql`

```bash
docker stop odoo
docker rm odoo

docker run -d \
  --link odoo-postgresql:postgresql \
  -e ODOO_DATABASE_NAME=odoo \
  -e ODOO_ADMIN_PASSWORD=Pa55w0rd \
  -e ODOO_ADMIN_EMAIL=admin@local.host \
  -e ODOO_COMPANY="Acme Pte Ltd" \
  -e ODOO_INSTALL_MODULES="website" \
  -e ODOO_LANG=en_US \
  -p 8069:8069 \
  -v /opt/docker/odoo/etc:/etc/odoo \
  -v /opt/docker/odoo/addons:/opt/odoo/extra \
  -v /opt/docker/odoo/lib:/var/lib/odoo \  
  -v /opt/docker/odoo/log:/var/log/odoo \
  --name odoo \
  madharjan/docker-odoo:12.0
```

## Run via Systemd

### Systemd Unit File - basic example

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

### Generate Systemd Unit File

| Variable                 | Default                     | Example                                                          |
|--------------------------|-----------------------------|------------------------------------------------------------------|
| PORT                     | 8080                        | 8000                                                             |
| VOLUME_HOME              | /opt/docker                 | /opt/data                                                        |
| VERSION                  | 12.0                        | latest                                                           |
| ODOO_DATABASE_NAME       | demo                        |                                                                  |
| ODOO_ADMIN_PASSWORD      | Pa55w0rd                    |                                                                  |
| ODOO_ADMIN_EMAIL         | root@localhost.localdomain  |                                                                  |
| ODOO_COMPANY             | Acme Pte Ltd                |                                                                  |
| ODOO_INSTALL_MODULES     | website                     | website,projects,inventory,blogs                                 |
| ODOO_UNINSTALL_MODULES   |                             |                                                                  |
| ODOO_LANG                | en_US                       |                                                                  |
| POSGRESQL_DATABASE       | postgresql                  |                                                                  |

```bash
docker run --rm -it \
  -e PORT=5432 \
  -e VOLUME_HOME=/opt/docker \
  -e VERSION=9.5 \
  -e POSTGRESQL_DATABASE=odoo \
  -e POSTGRESQL_USERNAME=odoo \
  -e POSTGRESQL_PASSWORD=odoo \
  madharjan/docker-postgresql:9.5 \
  /bin/sh -c "postgresql-systemd-unit" | \
  sudo tee /etc/systemd/system/postgresql.service

sudo systemctl enable postgresql
sudo systemctl start postgresql
```

```bash
docker run --rm -it \
  -e PORT=8080 \
  -e VOLUME_HOME=/opt/docker \
  -e VERSION=12.0 \
  -e POSGRESQL_DATABASE=postgresql \
  -e ODOO_DATABASE_NAME=demo \
  -e ODOO_ADMIN_PASSWORD=Pa55w0rd \
  -e ODOO_ADMIN_EMAIL=root@localhost.localdomain \
  -e ODOO_COMPANY="Acme Pte Ltd" \
  -e ODOO_INSTALL_MODULES="website" \
  -e ODOO_UNINSTALL_MODULES="discuss" \
  -e ODOO_LANG=${ODOO_LANG} \
  madharjan/docker-odoo:12.0 \
  /bin/sh -c "odoo-systemd-unit" | \
  sudo tee /etc/systemd/system/odoo.service

sudo systemctl enable odoo
sudo systemctl start odoo
```
