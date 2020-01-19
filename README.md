# docker-kibana

Containerized, ARM version of kibana. Compatible with Raspberry Pi

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
docker buildx build --platform linux/arm -t jmb12686/kibana:latest --push .
```

## How to Run

Run on a single Docker engine node:

```bash
sudo docker run --rm -p 5601:5601 \
  -v /home/pi/raspi-docker-stacks/elk/kibana/config/kibana.yml:/opt/kibana/config/kibana.yml \
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

2. Evaluate options to speed up build.  npm build of `nodegit` and `ctags` take very long, potential options include:

    * Extracting / caching the compiled `nodegit` and `ctags` download the cached binaries during build.

    * Investigate if bumping Kibana to newer version would eliminate the dependencies.  See post regarding this topic <https://discuss.elastic.co/t/installing-kibana-on-a-raspberry-pi-4-using-raspbian-buster/202612/7>

3. Break the dockerfile into multistage build
