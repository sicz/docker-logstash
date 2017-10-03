#!/bin/bash -e

### LOGSTASH_YML ###############################################################

if [ ! -e ${LS_SETTINGS_DIR}/logstash.docker.yml ]; then
  info "Creating ${LS_SETTINGS_DIR}/logstash.docker.yml"
  (
    echo "node.name: ${LS_NODE_NAME}"
    echo "path.data: ${LS_PATH_DATA}"
    echo "path.logs: ${LS_PATH_LOGS}"
  ) > ${LS_SETTINGS_DIR}/logstash.docker.yml
fi

LOGSTASH_YML_FILES="logstash.docker.yml ${LOGSTASH_YML_FILES}"

################################################################################
