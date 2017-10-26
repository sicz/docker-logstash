#!/bin/bash -e

### X-PACK_MONITORING ##########################################################

# X-Pack Monitoring is enabled by default
: ${XPACK_MONITORING_ENABLED:=true}

# X-Pack Monitoring endpoint
: ${XPACK_MONITORING_ELASTICSEARCH_URL:=${ELASTICSEARCH_URL}}

# Wait for Elasticsearch container DNS record
if [ "${XPACK_MONITORING_ENABLED}" = "true" \
  -a "${XPACK_MONITORING_ELASTICSEARCH_URL}" != "${ELASTICSEARCH_URL}" \
]; then
  WAIT_FOR_DNS="${WAIT_FOR_DNS} ${XPACK_MONITORING_ELASTICSEARCH_URL}"
fi

# X-Pack Monitoring user name and password
: ${XPACK_MONITORING_ELASTICSEARCH_USERNAME:=logstash_system}
if [ -e /run/secrets/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}.pwd ]; then
  : ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE:=/run/secrets/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}.pwd}
else
  : ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE:=${LS_SETTINGS_DIR}/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}.pwd}
fi
if [ -e ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE} ]; then
  XPACK_MONITORING_ELASTICSEARCH_PASSWORD="$(cat ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE})"
fi
# X-Pack Monitoring requires Elasticsearch user password even if not used
: ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD:=changeme}

### X-PACK_MANAGEMENT ##########################################################

# X-Pack Management is disabled by default
: ${XPACK_MANAGEMENT_ENABLED:=false}

# X-Pack Management endpoint
: ${XPACK_MANAGEMENT_ELASTICSEARCH_URL=${ELASTICSEARCH_URL}}

# Wait for Elasticsearch container DNS record
if [ "${XPACK_MANAGEMENT_ENABLED}" = "true" \
  -a "${XPACK_MANAGEMENT_ELASTICSEARCH_URL}" != "${ELASTICSEARCH_URL}" \
  -a "${XPACK_MANAGEMENT_ELASTICSEARCH_URL}" != "${XPACK_MONITORING_ELASTICSEARCH_URL}" \
]; then
  WAIT_FOR_DNS="${WAIT_FOR_DNS} ${XPACK_MANAGEMENT_ELASTICSEARCH_URL}"
fi

# X-Pack Management user name and password
: ${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME:=logstash_system}
if [ -e /run/secrets/es_${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}.pwd ]; then
  : ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE:=/run/secrets/es_${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}.pwd}
else
  : ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE:=${LS_SETTINGS_DIR}/es_${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}.pwd}
fi
if [ -e ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE} ]; then
  XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD="$(cat ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE})"
fi

################################################################################
