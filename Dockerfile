FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

LABEL description="Docker container for Odoo Server" os_version="Ubuntu 14.04"

ENV VERSION 9.0

ARG DEBUG=false

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/odoo/", "/var/lib/odoo", "/var/log/odoo"]

CMD ["/sbin/my_init"]

EXPOSE 5432
