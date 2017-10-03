#!/bin/bash -e

### LOGSTASH_YML ###############################################################

if [ ! -e ${LS_SETTINGS_DIR}/logstash.yml ]; then
  info "Creating ${LS_SETTINGS_DIR}/logstash.yml"
  (
    for LOGSTASH_YML_FILE in ${LOGSTASH_YML_FILES}; do
      echo "# ${LOGSTASH_YML_FILE}"
      cat ${LS_SETTINGS_DIR}/${LOGSTASH_YML_FILE}
    done
  ) > ${LS_SETTINGS_DIR}/logstash.yml
  if [ -n "${DOCKER_ENTRYPOINT_DEBUG}" ]; then
    cat ${LS_SETTINGS_DIR}/logstash.yml
  fi
fi

### LOG4J2_PROPERTIES ##########################################################

if [ ! -e ${LS_SETTINGS_DIR}/log4j2.properties ]; then
  info "Creating ${LS_SETTINGS_DIR}/log4j2.properties"
  (
    for LOG4J2_PROPERTIES_FILE in ${LOG4J2_PROPERTIES_FILES}; do
      echo "# ${LOG4J2_PROPERTIES_FILE}"
      cat ${LS_SETTINGS_DIR}/${LOG4J2_PROPERTIES_FILE}
    done
  ) > ${LS_SETTINGS_DIR}/log4j2.properties
  if [ -n "${DOCKER_ENTRYPOINT_DEBUG}" ]; then
    cat ${LS_SETTINGS_DIR}/log4j2.properties
  fi
fi

################################################################################
