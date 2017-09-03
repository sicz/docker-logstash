### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= $(DOCKER_PROJECT)/openjdk
BASE_IMAGE_TAG		?= 8u141-jre-centos

### DOCKER_IMAGE ###############################################################

LOGSTASH_VERSION	?= 5.5.2

DOCKER_PROJECT		?= sicz
DOCKER_PROJECT_DESC	?= An advanced open source ETL processor
DOCKER_PROJECT_URL	?= https://www.elastic.co/products/logstash

DOCKER_NAME		?= logstash
DOCKER_IMAGE_TAG	?= $(LOGSTASH_VERSION)
DOCKER_IMAGE_TAGS	?= latest

### DOCKER_VERSIONS ############################################################

DOCKER_VERSIONS		?= latest devel

### BUILD ######################################################################

# Docker image build variables
BUILD_VARS		+= LOGSTASH_VERSION

# Allows a change of the build/restore targets to the docker-tag if
# the development version is the same as the latest version
DOCKER_CI_TARGET	?= all
DOCKER_BUILD_TARGET	?= docker-build
DOCKER_REBUILD_TARGET	?= docker-rebuild

### DOCKER_EXECUTOR ############################################################

# Use the Docker Compose executor
DOCKER_EXECUTOR		?= compose

# Use the same service name for all configurations
SERVICE_NAME		?= container

# Certificate subject aletrnative names
SERVER_CRT_HOST		+= $(SERVICE_NAME).local

# Variables used in the Docker Compose file
COMPOSE_VARS		+= SERVER_CRT_HOST \
			   SERVICE_NAME \
			   SIMPLE_CA_IMAGE

### SIMPLE_CA ##################################################################

# Docker image dependencies
DOCKER_IMAGE_DEPENDENCIES += $(SIMPLE_CA_IMAGE)

# Simple CA image
SIMPLE_CA_IMAGE_NAME	?= sicz/simple-ca
SIMPLE_CA_IMAGE_TAG	?= latest
SIMPLE_CA_IMAGE		?= $(SIMPLE_CA_IMAGE_NAME):$(SIMPLE_CA_IMAGE_TAG)

# Simple CA service name in the Docker Compose file
SIMPLE_CA_SERVICE_NAME	?= $(shell echo $(SIMPLE_CA_IMAGE_NAME) | sed -E -e "s|^.*/||" -e "s/[^[:alnum:]_]+/_/g")

# Simple CA container name
ifeq ($(DOCKER_EXECUTOR),container)
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)
else ifeq ($(DOCKER_EXECUTOR),compose)
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)_1
else ifeq ($(DOCKER_EXECUTOR),stack)
# TODO: Docker Swarm Stack executor
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)_1
else
$(error Unknown Docker executor "$(DOCKER_EXECUTOR)")
endif

### MAKE_VARS ##################################################################

# Display the make variables
MAKE_VARS		?= GITHUB_MAKE_VARS \
			   BASE_IMAGE_MAKE_VARS \
			   DOCKER_IMAGE_MAKE_VARS \
			   BUILD_MAKE_VARS \
			   BUILD_TARGETS_MAKE_VARS \
			   EXECUTOR_MAKE_VARS \
			   CONFIG_MAKE_VARS \
			   SHELL_MAKE_VARS \
			   DOCKER_REGISTRY_MAKE_VARS \
			   DOCKER_VERSION_MAKE_VARS


define BUILD_TARGETS_MAKE_VARS
LOGSTAH_VERSION:	$(LOGSTAH_VERSION)

DOCKER_CI_TARGET:	$(DOCKER_CI_TARGET)
DOCKER_BUILD_TARGET:	$(DOCKER_BUILD_TARGET)
DOCKER_REBUILD_TARGET:	$(DOCKER_REBUILD_TARGET)
endef
export BUILD_TARGETS_MAKE_VARS

define CONFIG_MAKE_VARS
SIMPLE_CA_IMAGE_NAME:	$(SIMPLE_CA_IMAGE_NAME)
SIMPLE_CA_IMAGE_TAG:	$(SIMPLE_CA_IMAGE_TAG)
SIMPLE_CA_IMAGE:	$(SIMPLE_CA_IMAGE)

SERVER_CRT_HOST:	$(SERVER_CRT_HOST)
endef
export CONFIG_MAKE_VARS

### DOCKER_VERSION_TARGETS #####################################################

DOCKER_ALL_VERSIONS_TARGETS ?= build rebuild ci clean

### MAKE_TARGETS ###############################################################

# Build a new image and run the tests
.PHONY: all
all: build clean start wait logs test

# Build a new image and run the tests
.PHONY: ci
ci: $(DOCKER_CI_TARGET)
	@$(MAKE) clean

### BUILD_TARGETS ##############################################################

# Build a new image with using the Docker layer caching
.PHONY: build
build: $(DOCKER_BUILD_TARGET)
	@true

# Build a new image without using the Docker layer caching
.PHONY: rebuild
rebuild: $(DOCKER_REBUILD_TARGET)
	@true

### EXECUTOR_TARGETS ###########################################################

# Display the configuration file
.PHONY: config-file
config-file: display-config-file

# Display the make variables
.PHONY: makevars vars
makevars vars: display-makevars

# Remove the containers and then run them fresh
.PHONY: run up
run up: docker-up

# Create the containers
.PHONY: create
create: docker-create .docker-$(DOCKER_EXECUTOR)-create-www

.docker-$(DOCKER_EXECUTOR)-create-www:
	@$(ECHO) "Copying spec/fixtures/logstash to $(CONTAINER_NAME):/usr/share"
	@docker cp $(TEST_DIR)/spec/fixtures/logstash $(CONTAINER_NAME):/usr/share
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

PROJECT_DIR		?= $(CURDIR)
MK_DIR			?= $(PROJECT_DIR)/../Mk
include $(MK_DIR)/docker.image.mk

################################################################################
