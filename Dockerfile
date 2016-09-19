FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

ARG VCS_REF
ARG ODOO_VERSION
ARG DEBUG=false

LABEL description="Docker container for Odoo Server" os_version="Ubuntu ${UBUNTU_VERSION}" \
      org.label-schema.vcs-ref=${VCS_REF} org.label-schema.vcs-url="https://github.com/madharjan/docker-odoo"

ENV ODOO_VERSION ${ODOO_VERSION}

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/odoo", "/opt/odoo/addons", "/var/log/odoo"]

CMD ["/sbin/my_init"]

EXPOSE 5432
