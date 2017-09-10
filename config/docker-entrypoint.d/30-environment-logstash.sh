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

# Default Elasticsearch user name and password file location
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

################################################################################
