#!/bin/bash -e

### LS_NODE ####################################################################

# Logstash node name
if [ -n "${DOCKER_HOST_NAME}" ]; then
  LS_NODE_NAME="${DOCKER_CONTAINER_NAME}@${DOCKER_HOST_NAME}"
else
  LS_NODE_NAME="${DOCKER_CONTAINER_NAME}"
fi

### LS_PATH ####################################################################

# Path to configuration file or directory
: ${LS_PATH_CONFIG=${LOGSTASH_HOME}/pipeline}

# Swarm service in replicated mode might use one volume for multiple
# nodes together
if [ -n "${DOCKER_HOST_NAME}" ]; then
  : ${LS_PATH_DATA:=${LOGSTASH_HOME}/data/${DOCKER_CONTAINER_NAME}}
  : ${LS_PATH_LOGS:=${LOGSTASH_HOME}/logs/${DOCKER_CONTAINER_NAME}}
else
  : ${LS_PATH_DATA:=${LOGSTASH_HOME}/data}
  : ${LS_PATH_LOGS:=${LOGSTASH_HOME}/logs}
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
  : ${ELASTICSEARCH_PASSWORD_FILE:=${LOGSTASH_HOME}/config/es_${ELASTICSEARCH_USERNAME}.pwd}
fi

# Export Logstash user name and password to be used in the Logstash filters
if [ -e ${ELASTICSEARCH_PASSWORD_FILE} ]; then
  export ELASTICSEARCH_USERNAME
  export ELASTICSEARCH_PASSWORD=$(cat ${ELASTICSEARCH_PASSWORD_FILE})
fi

### JAVA_KEYSTORE ##############################################################

# Default truststore and keystore directories
SERVER_CRT_DIR=${LOGSTASH_HOME}/config
SERVER_KEY_DIR=${LOGSTASH_HOME}/config

### XPACK_MONITORING ###########################################################

# By default, X-Pack monitoring is disabled
: ${XPACK_MONITORING_ENABLED:=false}

# Default Elasticsearch URL
if [ -n "${ELASTICSEARCH_URL}" ]; then
  : ${XPACK_MONITORING_ELASTICSEARCH_URL:=${ELASTICSEARCH_URL}}
fi

# Default X-Pack monitoring user name and password file location
: ${XPACK_MONITORING_ELASTICSEARCH_USERNAME:=monitoring}
if [ -e /run/secrets/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}_pwd ]; then
  : ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE:=/run/secrets/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}.pwd}
else
  : ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE:=${LOGSTASH_HOME}/config/es_${XPACK_MONITORING_ELASTICSEARCH_USERNAME}.pwd}
fi

# Load Logstash user password
if [ -e ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE} ]; then
  XPACK_MONITORING_ELASTICSEARCH_PASSWORD=$(cat ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE})
fi

# Delete unnecessary variable
unset XPACK_MONITORING_ELASTICSEARCH_PASSWORD_FILE

################################################################################
