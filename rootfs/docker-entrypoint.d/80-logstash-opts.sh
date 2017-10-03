#!/bin/bash -e

### LS_OPTS ####################################################################

if [ -n "${DOCKER_CONTAINER_START}" ]; then
  declare -a LS_OPTS
  while IFS="=" read -r KEY VAL; do
    if [ ! -z "${VAL}" ]; then
      LS_OPTS+=("--${KEY}=${VAL}")
    fi
  done < <(env | egrep "^[a-z_]+\.[a-z_]+" | egrep -v "^xpack\." | sort)
  set -- $@ ${LS_OPTS[@]}
  unset LS_OPTS
fi

### LS_PATH ####################################################################

# Set permissions
chown -R ${DOCKER_USER}:${DOCKER_GROUP} ${LS_SETTINGS_DIR} ${LS_PATH_CONF} ${LS_PATH_DATA} ${LS_PATH_LOGS}
chmod -R u=rwX,g=rX,o-rwx ${LS_SETTINGS_DIR} ${LS_PATH_CONF} ${LS_PATH_DATA} ${LS_PATH_LOGS}

# Export Logstash settings directory
export LS_SETTINGS_DIR

################################################################################
