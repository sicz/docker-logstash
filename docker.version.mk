### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= $(DOCKER_PROJECT)/openjdk
BASE_IMAGE_TAG		?= 8u144-jre-centos

### DOCKER_IMAGE ###############################################################

LOGSTASH_TAG		?= $(LOGSTASH_VERSION)

DOCKER_PROJECT		?= sicz
DOCKER_PROJECT_DESC	?= An advanced open source ETL processor
DOCKER_PROJECT_URL	?= https://www.elastic.co/products/logstash

DOCKER_NAME		?= logstash
DOCKER_IMAGE_TAG	?= $(LOGSTASH_TAG)

### BUILD ######################################################################

# Docker image build variables
BUILD_VARS		+= LOGSTASH_VERSION \
			   LOGSTASH_TAG

### EXECUTOR ###################################################################

# Use the Docker Compose executor
DOCKER_EXECUTOR		?= compose

# Variables used in the Docker Compose file
COMPOSE_VARS		+= ELASTICSEARCH_IMAGE \
			   SERVER_CRT_HOST \
			   SIMPLE_CA_IMAGE

# Certificate subject aletrnative names
SERVER_CRT_HOST		+= $(SERVICE_NAME).local

### ELASTICSEARCH ##############################################################

# Docker image dependencies
DOCKER_IMAGE_DEPENDENCIES += $(ELASTICSEARCH_IMAGE)

# Elasticsearch image
ELASTICSEARCH_IMAGE_NAME ?= $(DOCKER_PROJECT)/elasticsearch
ELASTICSEARCH_IMAGE_TAG	?= $(LOGSTASH_TAG)-x-pack
ELASTICSEARCH_IMAGE	?= $(ELASTICSEARCH_IMAGE_NAME):$(ELASTICSEARCH_IMAGE_TAG)

### SIMPLE_CA ##################################################################

# Docker image dependencies
DOCKER_IMAGE_DEPENDENCIES += $(SIMPLE_CA_IMAGE)

# Simple CA image
SIMPLE_CA_IMAGE_NAME	?= $(DOCKER_PROJECT)/simple-ca
SIMPLE_CA_IMAGE_TAG	?= latest
SIMPLE_CA_IMAGE		?= $(SIMPLE_CA_IMAGE_NAME):$(SIMPLE_CA_IMAGE_TAG)

### MAKE_VARS ##################################################################

# Display the make variables
MAKE_VARS		?= GITHUB_MAKE_VARS \
			   CONFIG_MAKE_VARS \
			   BASE_IMAGE_MAKE_VARS \
			   DOCKER_IMAGE_MAKE_VARS \
			   BUILD_MAKE_VARS \
			   EXECUTOR_MAKE_VARS \
			   SHELL_MAKE_VARS \
			   DOCKER_REGISTRY_MAKE_VARS


define CONFIG_MAKE_VARS
LOGSTASH_VERSION:	$(LOGSTASH_VERSION)
LOGSTASH_TAG:		$(LOGSTASH_TAG)

ELASTICSEARCH_IMAGE_NAME: $(ELASTICSEARCH_IMAGE_NAME)
ELASTICSEARCH_IMAGE_TAG: $(ELASTICSEARCH_IMAGE_TAG)
ELASTICSEARCH_IMAGE:	$(ELASTICSEARCH_IMAGE)

SIMPLE_CA_IMAGE_NAME:	$(SIMPLE_CA_IMAGE_NAME)
SIMPLE_CA_IMAGE_TAG:	$(SIMPLE_CA_IMAGE_TAG)
SIMPLE_CA_IMAGE:	$(SIMPLE_CA_IMAGE)

SERVER_CRT_HOST:	$(SERVER_CRT_HOST)
endef
export CONFIG_MAKE_VARS

### MAKE_TARGETS ###############################################################

# Build a new image and run the tests
.PHONY: all
all: clean build start wait logs test

# Build a new image and run the tests
.PHONY: ci
ci: all
	@$(MAKE) clean

### BUILD_TARGETS ##############################################################

# Build a new image with using the Docker layer caching
.PHONY: build
build: docker-build

# Build a new image without using the Docker layer caching
.PHONY: rebuild
rebuild: docker-rebuild

### EXECUTOR_TARGETS ###########################################################

# Display the configuration file
.PHONY: config-file
config-file: display-config-file

# Display the make variables
.PHONY: vars
vars: display-makevars

# Remove the containers and then run them fresh
.PHONY: run up
run up: docker-up

# Create the containers
.PHONY: create
create: docker-create .docker-$(DOCKER_EXECUTOR)-create-logstash

.docker-$(DOCKER_EXECUTOR)-create-logstash:
	@$(ECHO) "Copying spec/fixtures/logstash/pipeline to $(CONTAINER_NAME):/usr/share/logstash"
	@docker cp $(TEST_DIR)/spec/fixtures/logstash/pipeline $(CONTAINER_NAME):/usr/share/logstash
	@$(ECHO) $(CONTAINER_NAME) > $@

# Start the containers
.PHONY: start
start: create docker-start

# Wait for the start of the containers
.PHONY: wait
wait: start docker-wait

# Display running containers
.PHONY: ps
ps: docker-ps

# Display the container logs
.PHONY: logs
logs: docker-logs

# Follow the container logs
.PHONY: logs-tail tail
logs-tail tail: docker-logs-tail

# Run shell in the container
.PHONY: shell sh
shell sh: start docker-shell

# Run the tests
.PHONY: test
test: start docker-test

# Run the shell in the test container
.PHONY: test-shell tsh
test-shell tsh:
	@$(MAKE) test TEST_CMD=/bin/bash

# Stop the containers
.PHONY: stop
stop: docker-stop

# Restart the containers
.PHONY: restart
restart: stop start

# Remove the containers
.PHONY: down rm
down rm: docker-rm

# Remove all containers and work files
.PHONY: clean
clean: docker-clean

### MK_DOCKER_IMAGE ############################################################

MK_DIR			?= $(PROJECT_DIR)/../Mk
include $(MK_DIR)/docker.image.mk

################################################################################
