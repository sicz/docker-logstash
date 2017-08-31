#!/bin/bash -e

### LS_PATH ####################################################################

# Create missing directories
mkdir -p ${LS_PATH_CONFIG} ${LS_PATH_DATA} ${LS_PATH_LOGS}

### XPACK_MONITORING ###########################################################

if [ -e ${JAVA_TRUSTSTORE_FILE} ]; then
  : ${XPACK_MONITORING_ELASTICSEARCH_SSL_TRUSTSTORE_PATH:=${JAVA_TRUSTSTORE_FILE}}
  : ${XPACK_MONITORING_ELASTICSEARCH_SSL_TRUSTSTORE_PASSWORD:=${JAVA_TRUSTSTORE_PWD}}
fi
if [ -e ${JAVA_KEYSTORE_FILE} ]; then
  : ${XPACK_MONITORING_ELASTICSEARCH_SSL_KEYSTORE_PATH:=${JAVA_KEYSTORE_FILE}}
  : ${XPACK_MONITORING_ELASTICSEARCH_SSL_KEYSTORE_PASSWORD:=${JAVA_KEYSTORE_PWD}}
fi

### LOGSTASH_YML ###############################################################

if [ ! -e ${LOGSTASH_HOME}/config/logstash.yml ]; then
  info "Creating logstash.yml"
  (
    for LOGSTASH_SETTINGS_FILE in ${LOGSTASH_SETTINGS_FILES}; do
      cat ${LOGSTASH_HOME}/config/${LOGSTASH_SETTINGS_FILE}
    done
    while IFS='=' read -r KEY VAL; do
      KEY=$(echo ${KEY} | sed -E 's/^LS_//' | tr '_[:upper:]' '.[:lower:]')
      if [ ! -z "${VAL}" ]; then
        echo "${KEY}: ${VAL}"
      fi
    done < <(set | egrep '^(LS|XPACK)_' | sort)
  ) > ${LOGSTASH_HOME}/config/logstash.yml
fi

### LOG4J2_PROPERTIES ##########################################################

if [ ! -e ${LOGSTASH_HOME}/config/log4j2.properties ]; then
  info "Creating log4j2.properties"
  (
    for LOG4J2_PROPERTIES_FILE in ${LOG4J2_PROPERTIES_FILES}; do
      cat ${LOGSTASH_HOME}/config/${LOG4J2_PROPERTIES_FILE}
    done
    while IFS='=' read -r KEY VAL; do
      LS_KEY=$(echo ${KEY} | sed -E 's/^LOG4J2_//' | tr '_[:upper:]' '.[:lower:]')
      if [ ! -z "${VAL}" ]; then
        echo "${KEY} = ${VAL}"
      fi
    done < <(set | egrep '^LOG4J2_' | sort | grep -v LOG4J2_PROPERTIES_FILE)
  ) > ${LOGSTASH_HOME}/config/log4j2.properties
fi

### LS_PATH ####################################################################

# Set permissions
chown -R ${DOCKER_USER}:${DOCKER_GROUP} ${LS_PATH_CONFIG} ${LS_PATH_DATA} ${LS_PATH_LOGS}
chmod -R o-rwx ${LS_PATH_CONFIG} ${LS_PATH_DATA} ${LS_PATH_LOGS}

################################################################################