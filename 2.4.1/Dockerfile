ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG LOGSTASH_VERSION
ARG LS_TARBALL="logstash-${LOGSTASH_VERSION}.tar.gz"
ARG LS_TARBALL_URL="https://download.elastic.co/logstash/logstash/${LS_TARBALL}"
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
  EXPECTED_SHA1=$(curl -fL ${LS_TARBALL_URL}.sha1.txt | cut -d " " -f 1); \
  TARBALL_SHA1=$(sha1sum /tmp/${LS_TARBALL} | cut -d " " -f 1); \
  [ "${TARBALL_SHA1}" = "${EXPECTED_SHA1}" ]; \
  tar xz --strip-components=1 -f /tmp/${LS_TARBALL}; \
  rm -f /tmp/${LS_TARBALL}; \
  chown -R root:root .

COPY rootfs /
