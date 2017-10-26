#!/bin/bash -e

### LOGSTASH_DOCKER_YML ########################################################

if [ ! -e ${LS_SETTINGS_DIR}/logstash.docker.yml ]; then
  info "Creating ${LS_SETTINGS_DIR}/logstash.docker.yml"
  (
    echo "node.name: ${LS_NODE_NAME}"
    echo "path.data: ${LS_PATH_DATA}"
    echo "path.logs: ${LS_PATH_LOGS}"
    while IFS="=" read -r KEY VAL; do
      if [ ! -z "${VAL}" ]; then
        echo "${KEY}: ${VAL}"
      fi
    done < <(env | egrep "^[a-z_]+\.[a-z_]+" | sort)
  ) > ${LS_SETTINGS_DIR}/logstash.docker.yml
fi

LOGSTASH_YML_FILES="logstash.docker.yml ${LOGSTASH_YML_FILES}"

################################################################################
