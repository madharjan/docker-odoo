# docker-odoo

[![](https://images.microbadger.com/badges/image/madharjan/docker-odoo.svg)](http://microbadger.com/images/madharjan/docker-odoo "Get your own image badge on microbadger.com")

Docker container for Odoo Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

* Odoo Server 9.0 (docker-odoo)

**Environment**

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

**Clone this project**
```
git clone https://github.com/madharjan/docker-odoo
cd docker-odoo
```

**Build Containers**
```
# login to DockerHub
docker login

# build
make

# test
make run
make tests
make clean

# tag
make tag_latest

# update Changelog.md
# release
make release
```

**Tag and Commit to Git**
```
git tag 9.0
git push origin 9.0
```

## Run Container

### PostgreSQL for Odoo

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/odoo/postgresql/etc/
sudo mkdir -p /opt/docker/odoo/postgresql/lib/
sudo mkdir -p /opt/docker/odoo/postgresql/log/
```

**Run `docker-postgresql`**
```
docker stop odoo-postgresql
docker rm odoo-postgresql

docker run -d \
  -e POSTGRESQL_USERNAME=odoo \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  -v /opt/docker/odoo/postgresql/etc:/etc/postgresql/9.3/main \
  -v /opt/docker/odoo/postgresql/lib:/var/lib/postgresql/9.3/main \
  -v /opt/docker/odoo/postgresql/log:/var/log/postgresql \
  --name odoo-postgresql \
  madharjan/docker-postgresql:9.3
```

### Odoo Server

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/odoo/etc/
sudo mkdir -p /opt/docker/odoo/addons/
sudo mkdir -p /opt/docker/odoo/lib/
sudo mkdir -p /opt/docker/odoo/log/
```

**Run `docker-odoo` linked with `docker-postgresql`**
```
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
  madharjan/docker-odoo:9.0
```

**Systemd Unit File**
```
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
ExecStartPre=-/usr/bin/docker pull madharjan/docker-odoo:9.0

ExecStart=/usr/bin/docker run \
  --link odoo-postgresql:postgresql \
  -p 172.17.0.1:8069:8069 \
  -v /opt/docker/odoo/etc:/etc/odoo \
  -v /opt/docker/odoo/addons:/opt/odoo/extra \
  -v /opt/docker/odoo/lib:/var/lib/odoo \  
  -v /opt/docker/odoo/log:/var/log/odoo \
  --name odoo \
  madharjan/docker-odoo:9.0

ExecStop=/usr/bin/docker stop -t 2 odoo

[Install]
WantedBy=multi-user.target
```
