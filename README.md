# docker-kibana

Multi-architecture (arm, x86) Docker image for Kibana

## TODO Fixes

Runtime error:

```bash
pi@raspberrypi-delta:~/raspi-docker-stacks $ sudo docker run --rm -p 5601:5601 -v /home/pi/raspi-docker-stacks/elk/kibana/config/kibana.yml:/opt/kibana/config/kibana.yml jmb12686/kibana
{"type":"log","@timestamp":"2020-01-17T21:40:01Z","tags":["fatal","root"],"pid":1,"message":"Error: /opt/kibana/node_modules/@elastic/nodegit/build/Release/nodegit.node: wrong ELF class: ELFCLASS64\n    at Object.Module._extensions..node (internal/modules/cjs/loader.js:718:18)\n    at Module.load (internal/modules/cjs/loader.js:599:32)\n    at tryModuleLoad (internal/modules/cjs/loader.js:538:12)\n    at Function.Module._load (internal/modules/cjs/loader.js:530:3)\n    at Module.require (internal/modules/cjs/loader.js:637:17)\n    at require (internal/modules/cjs/helpers.js:22:18)\n    at Object.<anonymous> (/opt/kibana/node_modules/@elastic/nodegit/dist/nodegit.js:12:12)\n    at Module._compile (internal/modules/cjs/loader.js:689:30)\n    at Module._compile (/opt/kibana/node_modules/pirates/lib/index.js:99:24)\n    at Module._extensions..js (internal/modules/cjs/loader.js:700:10)\n    at Object.newLoader [as .js] (/opt/kibana/node_modules/pirates/lib/index.js:104:7)\n    at Module.load (internal/modules/cjs/loader.js:599:32)\n    at tryModuleLoad (internal/modules/cjs/loader.js:538:12)\n    at Function.Module._load (internal/modules/cjs/loader.js:530:3)\n    at Module.require (internal/modules/cjs/loader.js:637:17)\n    at require (internal/modules/cjs/helpers.js:22:18)"}

 FATAL  Error: /opt/kibana/node_modules/@elastic/nodegit/build/Release/nodegit.node: wrong ELF class: ELFCLASS64
 ```
 
Potential Fix: https://discuss.elastic.co/t/installing-kibana-on-a-raspberry-pi-4-using-raspbian-buster/202612/6

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

```bash
sudo docker run --rm -p 5601:5601 -v /home/pi/raspi-docker-stacks/elk/kibana/config/kibana.yml:/opt/kibana/config/kibana.yml jmb12686/kibana
```
