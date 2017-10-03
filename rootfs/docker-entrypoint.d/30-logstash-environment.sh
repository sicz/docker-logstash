#!/bin/bash -e

### LS_PATH ####################################################################

# Path to settings directory
: ${LS_SETTINGS_DIR:=${LS_HOME}/config}

# Path to config, data and logs
: ${LS_PATH_CONF:=${LS_HOME}/pipeline}
: ${LS_PATH_DATA:=${LS_HOME}/data}
: ${LS_PATH_LOGS:=${LS_HOME}/logs}
# Swarm service in replicated mode might use one volume for multiple nodes
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

### LOG4J2_PROPERTIES ##########################################################

# Default Log4j2 properties file name
: ${LOG4J2_PROPERTIES_FILES:=log4j2.docker.properties}

### JAVA_KEYSTORE ##############################################################

# Default truststore and keystore directories
SERVER_CRT_DIR=${LS_SETTINGS_DIR}
SERVER_KEY_DIR=${LS_SETTINGS_DIR}

################################################################################
