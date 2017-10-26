#!/bin/bash -e

### CA_CERT ####################################################################

# Add CA certificate to Logstash settings dir
if [ -n "${CA_CRT_FILE}" -a -e "${CA_CRT_FILE}" -a ! -e "${LS_SETTINGS_DIR}/ca.crt" ]; then
  if [ "${CA_CRT_FILE}" != "${LS_SETTINGS_DIR}/ca.crt" ]; then
    info "Creating link ${LS_SETTINGS_DIR}/ca.crt => ${CA_CRT_FILE}"
    ln -s ${CA_CRT_FILE} ${LS_SETTINGS_DIR}/ca.crt
  fi
fi

### SERVER_CERT ################################################################

# Add server private key to Logstash settings dir
if [ -n "${SERVER_KEY_FILE}" -a -e "${SERVER_KEY_FILE}" -a ! -e "${LS_SETTINGS_DIR}/server.key" ]; then
  if [ "${SERVER_KEY_FILE}" != "${LS_SETTINGS_DIR}/server.key" ]; then
    info "Creating link ${LS_SETTINGS_DIR}/server.key => ${SERVER_KEY_FILE}"
    ln -s ${SERVER_KEY_FILE} ${LS_SETTINGS_DIR}/server.key
  fi
fi

# Add server certificate to Logstash settings dir
if [ -n "${SERVER_CRT_FILE}" -a -e "${SERVER_CRT_FILE}" -a ! -e "${LS_SETTINGS_DIR}/server.crt" ]; then
  if [ "${SERVER_CRT_FILE}" != "${LS_SETTINGS_DIR}/server.crt" ]; then
    info "Creating link ${LS_SETTINGS_DIR}/server.crt => ${SERVER_CRT_FILE}"
    ln -s ${SERVER_CRT_FILE} ${LS_SETTINGS_DIR}/ca.crt
  fi
fi

# Export server private key passphrase to Logstash config files
export SERVER_KEY_PWD

### JAVA_TRUSTSTORE ############################################################

# Add Java truststore to Logstash settings dir
if [ -n "${JAVA_TRUSTSTORE_FILE}" -a -e "${JAVA_TRUSTSTORE_FILE}" -a ! -e "${LS_SETTINGS_DIR}/truststore.jks" ]; then
  if [ "${JAVA_TRUSTSTORE_FILE}" != "${LS_SETTINGS_DIR}/truststore.jks" ]; then
    info "Creating link ${LS_SETTINGS_DIR}/truststore.jks => ${JAVA_TRUSTSTORE_FILE}"
    ln -s ${JAVA_TRUSTSTORE_FILE} ${LS_SETTINGS_DIR}/truststore.jks
  fi
fi

# Export Java truststore passphrase to Logstash config files
export JAVA_TRUSTSTORE_PWD

### JAVA_KEYSTORE ##############################################################

# Add Java keystore to Logstash settings dir
if [ -n "${JAVA_KEYSTORE_FILE}" -a -e "${JAVA_KEYSTORE_FILE}" -a ! -e "${LS_SETTINGS_DIR}/keystore.jks" ]; then
  if [ "${JAVA_KEYSTORE_FILE}" != "${LS_SETTINGS_DIR}/keystore.jks" ]; then
    info "Creating link ${LS_SETTINGS_DIR}/keystore.jks => ${JAVA_KEYSTORE_FILE}"
    ln -s ${JAVA_KEYSTORE_FILE} ${LS_SETTINGS_DIR}/keystore.jks
  fi
fi

# Export Java keystore passphrase to Logstash config files
export JAVA_KEYSTORE_PWD

################################################################################
