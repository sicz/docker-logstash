#!/bin/bash -e

### LS_PATH ####################################################################

# Create missing directories
for DIR in ${LS_SETTINGS_DIR} ${LS_PATH_CONFIG} ${LS_PATH_DATA} ${LS_PATH_LOGS}; do
  if [ ! -e ${DIR} ]; then
    debug "Creating directory ${DIR}"
    mkdir -p ${DIR}
  fi
done

### XPACK_MONITORING ###########################################################

if [ "${XPACK_MONITORING_ENABLED}" = "true" ]; then
  if [ -e ${JAVA_TRUSTSTORE_FILE} ]; then
    : ${XPACK_MONITORING_ELASTICSEARCH_SSL_TRUSTSTORE_PATH:=${JAVA_TRUSTSTORE_FILE}}
    : ${XPACK_MONITORING_ELASTICSEARCH_SSL_TRUSTSTORE_PASSWORD:=${JAVA_TRUSTSTORE_PWD}}
  fi
  if [ -e ${JAVA_KEYSTORE_FILE} ]; then
    : ${XPACK_MONITORING_ELASTICSEARCH_SSL_KEYSTORE_PATH:=${JAVA_KEYSTORE_FILE}}
    : ${XPACK_MONITORING_ELASTICSEARCH_SSL_KEYSTORE_PASSWORD:=${JAVA_KEYSTORE_PWD}}
  fi
fi

### LOGSTASH_YML ###############################################################

if [ ! -e ${LS_SETTINGS_DIR}/logstash.yml ]; then
  info "Creating ${LS_SETTINGS_DIR}/logstash.yml"
  echo > ${LS_SETTINGS_DIR}/logstash.yml
  for LS_SETTINGS_FILE in ${LS_SETTINGS_FILES}; do
    debug "Adding file ${LS_SETTINGS_FILE}"
    cat ${LS_SETTINGS_DIR}/${LS_SETTINGS_FILE} >> ${LS_SETTINGS_DIR}/logstash.yml
  done
  while IFS='=' read -r KEY VAL; do
    if [ ! -z "${VAL}" ]; then
      echo "${KEY}: ${VAL}" >> ${LS_SETTINGS_DIR}/logstash.yml
    fi
  done < <(set | egrep "^(LS|XPACK)_" | egrep -v "^(LS_SETTINGS_)" | sed -E 's/^LS_//' | tr '_[:upper:]' '.[:lower:]' | sort)
  if [ -n "${DOCKER_ENTRYPOINT_DEBUG}" ]; then
    cat ${LS_SETTINGS_DIR}/logstash.yml
  fi
fi

### LOG4J2_PROPERTIES ##########################################################

if [ ! -e ${LS_SETTINGS_DIR}/log4j2.properties ]; then
  info "Creating ${LS_SETTINGS_DIR}/log4j2.properties"
  echo > ${LS_SETTINGS_DIR}/log4j2.properties
  for LOG4J2_PROPERTIES_FILE in ${LOG4J2_PROPERTIES_FILES}; do
    debug "Adding file ${LOG4J2_PROPERTIES_FILE}"
    cat ${LS_SETTINGS_DIR}/${LOG4J2_PROPERTIES_FILE} >> ${LS_SETTINGS_DIR}/log4j2.properties
  done
  while IFS='=' read -r KEY VAL; do
    if [ ! -z "${VAL}" ]; then
      echo "${KEY} = ${VAL}" >> ${LS_SETTINGS_DIR}/log4j2.properties
    fi
  done < <(set | egrep "^LOG4J2_" | egrep -v "^(LOG4J2_PROPERTIES_)" | sed -E 's/^LOG4J2_//' | tr '_[:upper:]' '.[:lower:]' | sort)
  if [ -n "${DOCKER_ENTRYPOINT_DEBUG}" ]; then
    cat ${LS_SETTINGS_DIR}/log4j2.properties
  fi
fi

### LS_PATH ####################################################################

# Set permissions
chown -R root:root ${LOGSTASH_HOME}
chown -R ${DOCKER_USER}:${DOCKER_GROUP} ${LS_SETTINGS_DIR} ${LS_PATH_CONFIG} ${LS_PATH_DATA} ${LS_PATH_LOGS}
chmod -R o-rwx ${LS_SETTINGS_DIR} ${LS_PATH_CONFIG} ${LS_PATH_DATA} ${LS_PATH_LOGS}

# Export Logstash settings dir
export LS_SETTINGS_DIR

################################################################################
