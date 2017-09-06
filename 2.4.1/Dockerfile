ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DOCKER_IMAGE_NAME
ARG DOCKER_IMAGE_TAG
ARG DOCKER_PROJECT_DESC
ARG DOCKER_PROJECT_URL
ARG BUILD_DATE
ARG GITHUB_URL
ARG VCS_REF

LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="${DOCKER_IMAGE_NAME}" \
  org.label-schema.version="${DOCKER_IMAGE_TAG}" \
  org.label-schema.description="${DOCKER_PROJECT_DESC}" \
  org.label-schema.url="${DOCKER_PROJECT_URL}" \
  org.label-schema.vcs-url="${GITHUB_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.build-date="${BUILD_DATE}"

ARG LOGSTASH_VERSION
ENV LOGSTASH_HOME=/usr/share/logstash
ARG LOGSTASH_TARBALL=logstash-${LOGSTASH_VERSION}.tar.gz
ARG LOGSTASH_TARBALL_URL=https://downloads.elastic.co/downloads/logstash/${LOGSTASH_TARBALL}
ARG LOGSTASH_TARBALL_SHA1_URL=${LOGSTASH_TARBALL_URL}.sha1.txt

ENV \
  DOCKER_USER=logstash \
  DOCKER_COMMAND=logstash \
  PATH=${LOGSTASH_HOME}/bin:${PATH}

WORKDIR ${LOGSTASH_HOME}

RUN set -exo pipefail; \
  adduser --uid 1000 --user-group --home-dir ${LOGSTASH_HOME} ${DOCKER_USER}; \
  curl -fLo /tmp/${LOGSTASH_TARBALL} ${LOGSTASH_TARBALL_URL}; \
  EXPECTED_SHA1=$(curl -fL ${LOGSTASH_TARBALL_SHA1_URL} | cut -d ' ' -f 1); \
  TARBALL_SHA1=$(sha1sum /tmp/${LOGSTASH_TARBALL} | cut -d ' ' -f 1); \
  [ "${TARBALL_SHA1}" = "${EXPECTED_SHA1}" ]; \
  tar xz --strip-components=1 -f /tmp/${LOGSTASH_TARBALL}; \
  rm -f /tmp/${LOGSTASH_TARBALL}; \
  mkdir -p config data logs pipeline; \
  chown -R root:root .; \
  mv config/logstash.yml config/logstash.default.yml; \
  mv config/log4j2.properties config/log4j2.default.properties

COPY config /
