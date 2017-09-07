#!/bin/bash -e

### LS_NODE ####################################################################

# Logstash node name
if [ -n "${DOCKER_HOST_NAME}" ]; then
  LS_NODE_NAME="${DOCKER_CONTAINER_NAME}@${DOCKER_HOST_NAME}"
else
  LS_NODE_NAME="${DOCKER_CONTAINER_NAME}"
fi

### LS_PATH ####################################################################

# Path to settings directory
: ${LS_SETTINGS_DIR:=${LOGSTASH_HOME}/config}

# Path to configuration file or directory
: ${LS_PATH_CONFIG=${LOGSTASH_HOME}/pipeline}

# Path do data and log directories
: ${LS_PATH_DATA:=${LOGSTASH_HOME}/data}
: ${LS_PATH_LOGS:=${LOGSTASH_HOME}/logs}
# Swarm service in replicated mode might use one volume for multiple nodes
if [ -n "${DOCKER_HOST_NAME}" ]; then
  LS_PATH_DATA=${LOGSTASH_HOME}/data/${DOCKER_CONTAINER_NAME}}
  LS_PATH_LOGS=${LOGSTASH_HOME}/logs/${DOCKER_CONTAINER_NAME}}
fi

### LOG4J2_PROPERTIES ##########################################################

# Default Log4j2 properties file name
: ${LOG4J2_PROPERTIES_FILES:=log4j2.docker.properties}

### ES_LOGSTASH_USERNAME #######################################################

# Default Logstash user name and password file location
: ${ELASTICSEARCH_USERNAME:=logstash}
if [ -e /run/secrets/es_${ELASTICSEARCH_USERNAME}_pwd ]; then
  : ${ELASTICSEARCH_PASSWORD_FILE:=/run/secrets/es_${ELASTICSEARCH_USERNAME}.pwd}
else
  : ${ELASTICSEARCH_PASSWORD_FILE:=${LS_SETTINGS_DIR}/es_${ELASTICSEARCH_USERNAME}.pwd}
fi

# Export Logstash user name and password to be used in the Logstash filters
if [ -e ${ELASTICSEARCH_PASSWORD_FILE} ]; then
  export ELASTICSEARCH_USERNAME
  export ELASTICSEARCH_PASSWORD=$(cat ${ELASTICSEARCH_PASSWORD_FILE})
fi

### JAVA_KEYSTORE ##############################################################

# Default truststore and keystore directories
SERVER_CRT_DIR=${LS_SETTINGS_DIR}
SERVER_KEY_DIR=${LS_SETTINGS_DIR}

### XPACK_CONFIG ###############################################################

# By default, X-Pack capabilities are disabled
: ${XPACK_MANAGEMENT_ENABLED:=false}    # From Logstash 6.0.0
: ${XPACK_MONITORING_ENABLED:=false}    # From Logstash 5.0.0

# Default Elasticsearch URL

# Default X-Pack monitoring URL, user name and password file location
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

# Default X-Pack management URL, user name and password file location
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

################################################################################
