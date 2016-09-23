#!/bin/bash

set -x

docker stop odoo
docker rm odoo

docker stop odoo-postgresql
docker rm odoo-postgresql

sudo rm -rf /opt/docker/odoo
