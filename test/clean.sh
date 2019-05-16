#!/bin/bash

set -x

docker stop odoo 2> /dev/null
docker rm odoo 2> /dev/null

docker stop odoo-postgresql 2> /dev/null
docker rm odoo-postgresql 2> /dev/null

sudo rm -rf /opt/docker/odoo
