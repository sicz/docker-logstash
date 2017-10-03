#!/bin/bash -e

### LOGSTASH_YML ###############################################################

if [ ! -e ${LS_SETTINGS_DIR}/logstash.x-pack.docker.yml ]; then
  (
    # X-Pack Monitoring settings
    if [ "${XPACK_MONITORING_ENABLED}" = "true" -a -n "${XPACK_MONITORING_ELASTICSEARCH_URL}" ]; then
      echo "xpack.monitoring.enabled: ${XPACK_MONITORING_ENABLED}"
      echo "xpack.monitoring.elasticsearch.url: ${XPACK_MONITORING_ELASTICSEARCH_URL}"
      if [ -n "${XPACK_MONITORING_ELASTICSEARCH_USERNAME}" -a -n "${XPACK_MONITORING_ELASTICSEARCH_PASSWORD}" ]; then
        echo "xpack.monitoring.elasticsearch.username: ${XPACK_MONITORING_ELASTICSEARCH_USERNAME}"
        echo "xpack.monitoring.elasticsearch.password: ${XPACK_MONITORING_ELASTICSEARCH_PASSWORD}"
      fi
      if [ "$(echo "${XPACK_MONITORING_ELASTICSEARCH_URL}" | sed -E "s|://.*||")" = "https" ]; then
        if [ -n "${JAVA_TRUSTSTORE_FILE}" -a -e "${JAVA_TRUSTSTORE_FILE}" ]; then
          echo "xpack.monitoring.elasticsearch.ssl.truststore.path: ${JAVA_TRUSTSTORE_FILE}"
          echo "xpack.monitoring.elasticsearch.ssl.truststore.password: ${JAVA_TRUSTSTORE_PWD}"
        fi
        if [ -n "${JAVA_KEYSTORE_FILE}" -a -e "${JAVA_KEYSTORE_FILE}" ]; then
          echo "xpack.monitoring.elasticsearch.ssl.keystore.path: ${JAVA_KEYSTORE_FILE}"
          echo "xpack.monitoring.elasticsearch.ssl.keystore.password: ${JAVA_KEYSTORE_PWD}"
        fi
      fi
    else
      echo "xpack.monitoring.enabled: false"
    fi
    # X-Pack Management settings
    if [ "${XPACK_MANAGEMENT_ENABLED}" = "true" -a -n "${XPACK_MANAGEMENT_ELASTICSEARCH_URL}" ]; then
      echo "xpack.management.enabled: ${XPACK_MANAGEMENT_ENABLED}"
      echo "xpack.management.elasticsearch.url: ${XPACK_MANAGEMENT_ELASTICSEARCH_URL}"
      if [ -n "${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}" -a -n "${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD}" ]; then
        echo "xpack.management.elasticsearch.username: ${XPACK_MANAGEMENT_ELASTICSEARCH_USERNAME}"
        echo "xpack.management.elasticsearch.password: ${XPACK_MANAGEMENT_ELASTICSEARCH_PASSWORD}"
      fi
      if [ "$(echo "${XPACK_MANAGEMENT_ELASTICSEARCH_URL}" | sed -E "s|://.*||")" = "https" ]; then
        if [ -n "${JAVA_TRUSTSTORE_FILE}" -a -e "${JAVA_TRUSTSTORE_FILE}" ]; then
          echo "xpack.management.elasticsearch.ssl.truststore.path: ${JAVA_TRUSTSTORE_FILE}"
          echo "xpack.management.elasticsearch.ssl.truststore.password: ${JAVA_TRUSTSTORE_PWD}"
        fi
        if [ -n "${JAVA_KEYSTORE_FILE}" -a -e "${JAVA_KEYSTORE_FILE}" ]; then
          echo "xpack.management.elasticsearch.ssl.keystore.path: ${JAVA_KEYSTORE_FILE}"
          echo "xpack.management.elasticsearch.ssl.keystore.password: ${JAVA_KEYSTORE_PWD}"
        fi
      fi
    else
      # TODO: Logstash 5 X-Pack does not support X-Pack Management
      if [ "$(echo ${LOGSTASH_VERSION} | sed -E "s/\..*//")" != "5" ]; then
        echo "xpack.management.enabled: false"
      fi
    fi
    # Environment variables settings
    while IFS="=" read -r KEY VAL; do
      if [ ! -z "${VAL}" ]; then
        echo "${KEY}: ${VAL}"
      fi
    done < <(env | egrep "^xpack\.[a-z_]+" | sort)
  ) > ${LS_SETTINGS_DIR}/logstash.x-pack.docker.yml
fi

LOGSTASH_YML_FILES="${LOGSTASH_YML_FILES} logstash.x-pack.docker.yml"

################################################################################
