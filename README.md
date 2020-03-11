# docker-kibana

<p align="center">
  <a href="https://hub.docker.com/r/jmb12686/kibana/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/jmb12686/docker-kibana?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/jmb12686/docker-kibana/actions"><img src="https://github.com/jmb12686/docker-kibana/workflows/build/badge.svg" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/jmb12686/kibana/"><img src="https://img.shields.io/docker/stars/jmb12686/kibana.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/jmb12686/kibana/"><img src="https://img.shields.io/docker/pulls/jmb12686/kibana.svg?style=flat-square" alt="Docker Pulls"></a>

Containerized, multiarch version of [Kibana](https://github.com/elastic/kibana). Designed to be usable within x86-64, armv6, and armv7 based Docker Swarm clusters. Compatible with all Raspberry Pi models (armv6 + armv7).

## Usage

Run on a single Docker engine node:

```bash
sudo docker run --rm -p 5601:5601 \
  -v ${PWD}/config/example/kibana.yml:/opt/kibana/config/kibana.yml \
  jmb12686/kibana
```

Run with with Compose on Docker Swarm:

```yml
version: "3.7"
services:
  kibana:
    image: jmb12686/kibana
    ports:
      - 5601:5601
    configs:
      - source: kibana_config
        target: /opt/kibana/config/kibana.yml
    networks:
      - elk
    deploy:
      mode: replicated
      replicas: 1
      resources:
        limits:
          memory: 1024M
        reservations:
            memory: 1024M
configs:
  kibana_config:
    name: kibana_config-${CONFIG_VERSION:-0}
    file: ./kibana/config/kibana.yml
networks:
  elk:
    driver: overlay
```

## TODO Errors

When navigating to the 'Discovery' tab, receive following error in UI:

`No indices match pattern "apm-*"`

This may be resolved simply by adding configuration in filebeat to setup index template on startup

## TODO Fixes

1. Tweak the `apt install` blocks.  I had to break them apart while debugging hanging build.

2. Break the dockerfile into multistage build, push builder stage as described here: <https://pythonspeed.com/articles/faster-multi-stage-builds/>

## How to Build

Build using `buildx` for multiarchitecture image and manifest support

Setup buildx

```bash
docker buildx create --name multiarchbuilder
docker buildx use multiarchbuilder
docker buildx inspect --bootstrap
[+] Building 0.0s (1/1) FINISHED
 => [internal] booting buildkit                                                                                                                 5.7s
 => => pulling image moby/buildkit:buildx-stable-1                                                                                              4.6s
 => => creating container buildx_buildkit_multiarchbuilder0                                                                                     1.1s
Name:   multiarchbuilder
Driver: docker-container

Nodes:
Name:      multiarchbuilder0
Endpoint:  npipe:////./pipe/docker_engine
Status:    running
Platforms: linux/amd64, linux/arm64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```

Build

```bash
docker buildx build --platform linux/arm,linux/amd64 -t jmb12686/kibana:latest --push .
```

##

Multiarchitecture builds are currently not working correctly for added plugins on ARM based platforms.  There appears to be an issue when running the optimization step for kibana after 
installing a plugin.  This seems to be only when using cross-compilation via QEMU and Docker Buildx.  For cross compiled plugin optimized images, run the following (while substituting your arch):

```bash
sudo docker build --platform linux/arm/v7 --build-arg TARGETPLATFORM=linux/arm/v7 --tag jmb12686/kibana:7.4.1-elastalert-arm
```


