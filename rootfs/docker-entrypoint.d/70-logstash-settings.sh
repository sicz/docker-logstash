#!/bin/bash -e

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


### PIPELINES_YML ##############################################################

if [ ! -e ${LS_SETTINGS_DIR}/pipelines.yml ]; then
  PIPELINE_YML_FILES="$(find ${LS_PATH_CONF} -maxdepth 2 -name pipeline.yml)"
  if [ -n "${PIPELINE_YML_FILES}" ]; then
    info "Creating ${LS_SETTINGS_DIR}/pipelines.yml"
    (
      for PIPELINE_YML_FILE in ${PIPELINE_YML_FILES}; do
        echo "# ${PIPELINE_YML_FILE}"
        cat ${LS_SETTINGS_DIR}/${PIPELINE_YML_FILE}
      done
    ) > ${LS_SETTINGS_DIR}/pipelines.yml
    if [ -n "${DOCKER_ENTRYPOINT_DEBUG}" ]; then
      cat ${LS_SETTINGS_DIR}/pipelines.yml
    fi
  fi
fi

################################################################################
