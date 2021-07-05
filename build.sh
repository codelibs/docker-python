#!/bin/bash

PYTHON_VERSION=3.9
PYTHON_OS_CODE=buster
DOCKER_FILE_URL=https://raw.githubusercontent.com/docker-library/python/master/${PYTHON_VERSION}/${PYTHON_OS_CODE}/Dockerfile
BUILD_OS_CODE=bionic
USE_BUILDX=false

echo "Downloading ${DOCKER_FILE_URL}"
curl ${DOCKER_FILE_URL} \
  | sed -e "s/buildpack-deps:$PYTHON_OS_CODE/buildpack-deps:$BUILD_OS_CODE\nENV DEBIAN_FRONTEND noninteractive/" \
        -e "s/ha.pool.sks-keyservers.net/ipv4.pool.sks-keyservers.net/g" \
  > Dockerfile

PYTHON_VERSION=`cat Dockerfile | grep "ENV PYTHON_VERSION" | awk '{ print $3 }'`
DOCKER_TAG=ghcr.io/codelibs/python:${PYTHON_VERSION}-${BUILD_OS_CODE}

echo "Building ${DOCKER_TAG}"
if [[ ${USE_BUILDX} != "true" ]] ; then
  docker build --rm -t ${DOCKER_TAG} .
else
  docker buildx build --rm --platform linux/amd64,linux/arm64 -t ${DOCKER_TAG} --push .
fi

