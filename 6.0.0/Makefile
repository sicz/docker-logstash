### DOCKER_IMAGE ###############################################################

LOGSTASH_VERSION	?= 6.0.0-beta2

DOCKER_IMAGE_TAG	?= $(shell echo $(LOGSTASH_VERSION) | sed -E "s/-.*//")
DOCKER_IMAGE_TAGS	?= 6.0

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ..)
include $(PROJECT_DIR)/docker.version.mk

################################################################################
