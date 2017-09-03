# docker-logstash

[![CircleCI Status Badge](https://circleci.com/gh/sicz/docker-logstash.svg?style=shield&circle-token=1a76fa86dc68f2cee7f98dede7f0a9efef5b66b6)](https://circleci.com/gh/sicz/docker-logstash)

**This project is not aimed at public consumption.
It exists to serve as a single endpoint for SICZ containers.**

An advanced open source ETL processor.

## Contents

This container only contains essential components:
* [sicz/openjdk:8-jre-centos](https://github.com/sicz/docker-openjdk)
  as a base image.
* [Logstash](https://www.elastic.co/products/logstash) provides an advanced
  open source ETL processor.
* [Logstash X-Pack plugin](https://www.elastic.co/products/x-pack) adds
  monitoring to Logstash

## Getting started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See deployment for notes
on how to deploy the project on a live system.

### Installing

Clone the GitHub repository into your working directory:
```bash
git clone https://github.com/sicz/docker-logstash
```

### Usage

Use the command `make` to simplify the Docker image development tasks:
```bash
make all                # Build a new image and run the tests
make ci                 # Build a new image and run the tests
make build              # Build a new image
make rebuild            # Build a new image without using the Docker layer caching
make config-file        # Display the configuration file for the current configuration
make vars               # Display the make variables for the current configuration
make up                 # Remove the containers and then run them fresh
make create             # Create the containers
make start              # Start the containers
make stop               # Stop the containers
make restart            # Restart the containers
make rm                 # Remove the containers
make wait               # Wait for the start of the containers
make ps                 # Display running containers
make logs               # Display the container logs
make logs-tail          # Follow the container logs
make shell              # Run the shell in the container
make test               # Run the tests
make test-shell         # Run the shell in the test container
make secrets            # Create the Simple CA secrets
make clean              # Remove all containers and work files
make docker-pull        # Pull all images from the Docker Registry
make docker-pull-dependencies # Pull the project image dependencies from the Docker Registry
make docker-pull-image  # Pull the project image from the Docker Registry
make docker-pull-testimage # Pull the test image from the Docker Registry
make docker-push        # Push the project image into the Docker Registry
```

`logstash` with the default configuration listens on TCP port 5000 and save
incoming events into file `/usr/share/logstash/data/events.json`.

## Deployment

You can start with this sample `docker-compose.yml` file:
```yaml
services:
  logstash:
    image: sicz/logstash
    ports:
      - 5000:5000
    volumes:
      - ./config:/usr/share/logstash/pipeline
```

## Authors

* [Petr Řehoř](https://github.com/prehor) - Initial work.

See also the list of [contributors](https://github.com/sicz/docker-baseimage-alpine/contributors)
who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the
[LICENSE](LICENSE) file for details.
