### DOCKER_IMAGE ###############################################################

LOGSTASH_VERSION	?= 2.4.1

DOCKER_IMAGE_TAGS	?= 2.4

### BUILD ######################################################################

BUILD_VARS		+= LOGSTASH_TARBALL \
			   LOGSTASH_TARBALL_URL \
			   LOGSTASH_TARBALL_SHA1_URL

LOGSTASH_TARBALL	?= logstash-${LOGSTASH_VERSION}.tar.gz
LOGSTASH_TARBALL_URL	?= https://download.elastic.co/logstash/logstash/$(LOGSTASH_TARBALL)
LOGSTASH_TARBALL_SHA1_URL ?= $(LOGSTASH_TARBALL_URL).sha1.txt

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ..)
include $(PROJECT_DIR)/docker.version.mk

################################################################################
