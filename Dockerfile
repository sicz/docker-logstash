ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG LOGSTASH_VERSION
ARG LS_TARBALL="logstash-${LOGSTASH_VERSION}.tar.gz"
ARG LS_TARBALL_URL="https://artifacts.elastic.co/downloads/logstash/${LS_TARBALL}"
ARG LS_HOME="/usr/share/logstash"

ENV \
  DOCKER_USER="logstash" \
  DOCKER_COMMAND="logstash" \
  ELASTIC_CONTAINER="true" \
  LOGSTASH_VERSION="${LOGSTASH_VERSION}" \
  LS_HOME="${LS_HOME}" \
  PATH="${LS_HOME}/bin:${PATH}"

WORKDIR ${LS_HOME}

RUN set -exo pipefail; \
  adduser --uid 1000 --user-group --home-dir ${LS_HOME} ${DOCKER_USER}; \
  curl -fLo /tmp/${LS_TARBALL} ${LS_TARBALL_URL}; \
  EXPECTED_CHECKSUM=$(curl -fL ${LS_TARBALL_URL}.sha512 | cut -d " " -f 1); \
  TARBALL_CHECKSUM=$(sha512sum /tmp/${LS_TARBALL} | cut -d " " -f 1); \
  [ "${TARBALL_CHECKSUM}" = "${EXPECTED_CHECKSUM}" ]; \
  tar xz --strip-components=1 -f /tmp/${LS_TARBALL}; \
  rm -f /tmp/${LS_TARBALL}; \
  chown -R root:root .; \
  mv config/logstash.yml config/logstash.default.yml; \
  mv config/log4j2.properties config/log4j2.default.properties

COPY rootfs /
