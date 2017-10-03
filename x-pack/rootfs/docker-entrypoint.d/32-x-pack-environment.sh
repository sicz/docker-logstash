#!/bin/bash -e

### XPACK_EDITION ##############################################################

# Default X-Pack edition - free Basic license
: ${XPACK_EDITION:=basic}

### ELASTICSEARCH ##############################################################

: ${ELASTICSEARCH_USERNAME:=logstash}
if [ -e /run/secrets/es_${ELASTICSEARCH_USERNAME}.pwd ]; then
  : ${ELASTICSEARCH_PASSWORD_FILE:="/run/secrets/es_${ELASTICSEARCH_USERNAME}.pwd"}
else
  : ${ELASTICSEARCH_PASSWORD_FILE:="${LS_SETTINGS_DIR}/es_${ELASTICSEARCH_USERNAME}.pwd"}
fi
if [ -e ${ELASTICSEARCH_PASSWORD_FILE} ]; then
  ELASTICSEARCH_PASSWORD="$(cat ${ELASTICSEARCH_PASSWORD_FILE})"
fi

if [ -n "${ELASTICSEARCH_URL}" ]; then
  export ELASTICSEARCH_URL ELASTICSEARCH_USERNAME ELASTICSEARCH_PASSWORD
fi

### X-PACK_MONITORING ##########################################################

# X-Pack Monitoring is enabled by default
: ${XPACK_MONITORING_ENABLED:=true}

# X-Pack Monitoring endpoint
: ${XPACK_MONITORING_ELASTICSEARCH_URL:=${ELASTICSEARCH_URL}}

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
