### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= $(DOCKER_IMAGE_NAME)
BASE_IMAGE_TAG		?= $(LOGSTASH_TAG)-x-pack

### DOCKER_IMAGE ###############################################################

DOCKER_IMAGE_TAG	?= $(LOGSTASH_TAG)-dev

### BUILD ######################################################################

VARIANT_DIR		?= $(PROJECT_DIR)/dev

### TEST #######################################################################

# Skip X-Pack tests
SPEC_OPTS		?= --tag ~x_pack

### ELASTICSEARCH ##############################################################

ELASTICSEARCH_IMAGE_TAG	?= $(BASE_IMAGE_TAG)

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ../..)
include ../Makefile

################################################################################
