ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN set -exo pipefail; \
  logstash-plugin install x-pack

COPY x-pack/rootfs /
