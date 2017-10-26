#!/bin/bash -e

### LS_PATH ####################################################################

# Path to settings directory
: ${LS_SETTINGS_DIR:=${LS_HOME}/config}

# Path to config, data and logs
: ${LS_PATH_CONF:=${LS_HOME}/pipeline}
: ${LS_PATH_DATA:=${LS_HOME}/data}
: ${LS_PATH_LOGS:=${LS_HOME}/logs}
# Docker Stack service in replicated mode might use one volume for multiple nodes
if [ -n "${DOCKER_HOST_NAME}" ]; then
  LS_PATH_DATA=${LOGSTASH_HOME}/data/${DOCKER_CONTAINER_NAME}}
  LS_PATH_LOGS=${LOGSTASH_HOME}/logs/${DOCKER_CONTAINER_NAME}}
fi

# Create missing directories
mkdir -p ${LS_SETTINGS_DIR} ${LS_PATH_CONF} ${LS_PATH_DATA} ${LS_PATH_LOGS}

# Populate Logstash settings directory
if [ "$(readlink -f ${LS_HOME}/config)" != "$(readlink -f ${LS_SETTINGS_DIR})" ]; then
  cp -rp ${LS_HOME}/config/* ${LS_SETTINGS_DIR}
fi

### LS_NODE ####################################################################

# Logstash node name
if [ -n "${DOCKER_HOST_NAME}" ]; then
  LS_NODE_NAME="${DOCKER_CONTAINER_NAME}@${DOCKER_HOST_NAME}"
else
  LS_NODE_NAME="${DOCKER_CONTAINER_NAME}"
fi

### ELASTICSEARCH_URL ##########################################################

if [ -n "${ELASTICSEARCH_URL}" ]; then
  # Elasticsearch user name and password
  : ${ELASTICSEARCH_USERNAME:=logstash}
  if [ -e /run/secrets/es_${ELASTICSEARCH_USERNAME}.pwd ]; then
    : ${ELASTICSEARCH_PASSWORD_FILE:="/run/secrets/es_${ELASTICSEARCH_USERNAME}.pwd"}
  else
    : ${ELASTICSEARCH_PASSWORD_FILE:="${LS_SETTINGS_DIR}/es_${ELASTICSEARCH_USERNAME}.pwd"}
  fi
  if [ -e ${ELASTICSEARCH_PASSWORD_FILE} ]; then
    ELASTICSEARCH_PASSWORD="$(cat ${ELASTICSEARCH_PASSWORD_FILE})"
  fi

  # Wait for Elasticsearch container DNS record
  WAIT_FOR_DNS="${WAIT_FOR_DNS} ${ELASTICSEARCH_URL}"

  # Export Elasticsearch URL for Logstash filters
  export ELASTICSEARCH_URL ELASTICSEARCH_USERNAME ELASTICSEARCH_PASSWORD
fi

### LOG4J2_PROPERTIES ##########################################################

# Default Log4j2 properties file name
: ${LOG4J2_PROPERTIES_FILES:=log4j2.docker.properties}

### SERVER_CERTS ###############################################################

# Default certificate and key directories
SERVER_CRT_DIR="${LS_SETTINGS_DIR}"
SERVER_KEY_DIR="${LS_SETTINGS_DIR}"

################################################################################
