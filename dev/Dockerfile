ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV JRUBY_HOME=${LS_HOME}/vendor/jruby
ENV PATH=${JRUBY_HOME}/bin:${PATH}

RUN set -exo pipefail; \
# Install the packages
yum install -y \
  gcc \
  git \
  "java-1.${OPENJDK_PRODUCT_VERSION}.0-openjdk-devel-1:1.${OPENJDK_PRODUCT_VERSION}.0.${OPENJDK_UPDATE_VERSION}-*" \
  make \
  vim-enhanced \
  ; \
# Cleanup yum
yum clean all; \
# Install Ruby packages
gem install \
  bundler \
  rake \
  rspec
