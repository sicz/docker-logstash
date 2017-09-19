#!/bin/bash -e

### XPACK_CONFIG ###############################################################

# By default, X-Pack capabilities are disabled
: ${XPACK_MANAGEMENT_ENABLED:=false}    # From Logstash 6.0.0
: ${XPACK_MONITORING_ENABLED:=false}    # From Logstash 5.0.0

### XPACK_MANAGEMENT ###########################################################

# Default X-Pack management URL, user name and password file location
if [ "${XPACK_MANAGEMENT_ENABLED}" = "true" ]; then
  if [ -n "${ELASTICSEARCH_URL}" ]; then
    : ${XPACK_MANAGEMENT_ELASTICSEARCH_URL:=${ELASTICSEARCH_URL}}
  fi
  : ${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME:=logstash}
  if [ -e /run/secrets/es_${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}_pwd ]; then
    : ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE:=/run/secrets/es_${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}.pwd}
  else
    : ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE:=${LS_SETTINGS_DIR}/es_${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}.pwd}
  fi
  if [ -e ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE} ]; then
    XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD=$(cat ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE})
  fi
  unset XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD_FILE
fi

### XPACK_MONITORING ###########################################################

# Default X-Pack monitoring URL, user name and password file location
if [ "${XPACK_MONITORING_ENABLED}" = "true" ]; then
  if [ -n "${ELASTICSEARCH_URL}" ]; then
    : ${XPACK_MONITORING_ELASTICSEARCH_URL:=${ELASTICSEARCH_URL}}
  fi
  : ${XPACK_MONITORING_ELASTICSEARCH_USERNAME:=monitoring}
  if [ -e /run/secrets/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}_pwd ]; then
    : ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE:=/run/secrets/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}.pwd}
  else
    : ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE:=${LS_SETTINGS_DIR}/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}.pwd}
  fi
  if [ -e ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE} ]; then
    XPACK_MONITORING_ELASTICSEARCH_PASSWORD=$(cat ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE})
  fi
  unset XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE
fi

################################################################################