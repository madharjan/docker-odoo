# docker-odoo
Docker container for Odoo Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

* Odoo Server 9.0 (docker-odoo)

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
make test

# tag
make tag_latest

# update Makefile & Changelog.md
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

docker run -d -t \
  -e POSTGRESQL_USERNAME=odoo \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  -p 5432:5432 \
  -v /opt/docker/odoo/postgresql/etc:/etc/postgresql/9.3/main \
  -v /opt/docker/odoo/postgresql/lib:/var/lib/postgresql/9.3/main \
  -v /opt/docker/odoo/postgresql/log:/var/log/postgresql \
  --name odoo-postgresql \
  madharjan/docker-postgresql:9.3
```

### Odoo Server

**Run `docker-odoo`**
```
docker run -d -t \
  --name odoo \
  madharjan/docker-odoo:9.0
```

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/odoo/etc/
sudo mkdir -p /opt/docker/odoo/addons/
sudo mkdir -p /opt/docker/odoo/lib/
sudo mkdir -p /opt/docker/odoo/log/
```

**Copy default configuration to host**
```
sudo docker cp odoo:/etc/odoo/odoo-server.conf /opt/docker/odoo/etc/
```

**Update configuration as necessary**
```
sudo vi /opt/docker/odoo/etc/odoo-server.conf
```

**Run `docker-odoo` with update configuration**
```
docker stop odoo
docker rm odoo

docker run -d -t \
  --link odoo-postgresql:postgresql \
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
ExecStartPre=-/bin/mkdir -p /opt/docker/odoo/log
ExecStartPre=-/usr/bin/docker stop odoo
ExecStartPre=-/usr/bin/docker rm odoo
ExecStartPre=-/usr/bin/docker pull madharjan/docker-odoo:9.0

ExecStart=/usr/bin/docker run \
  --link odoo-postgresql:postgresql \
  -p 172.17.0.1:8069:8069 \
  -v /opt/docker/odoo/etc/:/etc/odoo \
  -v /opt/docker/odoo/addons:/opt/odoo/addons
  -v /opt/docker/odoo/log:/var/log/odoo \
  --name odoo \
  madharjan/docker-odoo:9.0

ExecStop=/usr/bin/docker stop -t 2 odoo

[Install]
WantedBy=multi-user.target
```
