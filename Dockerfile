FROM ubuntu:18.04

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG KIBANA_VERSION=7.5.1

###############################################################################
#                                INSTALLATION
###############################################################################

### install prerequisites


# RUN set -x \
RUN set -e \
 && apt update -y \
 && apt install -y --no-install-recommends ca-certificates \ 
 && apt install -y --no-install-recommends curl \
 && apt install -y --no-install-recommends gosu \
 && apt install -y --no-install-recommends wget \
 && apt install -y --no-install-recommends libkrb5-dev \
 && apt install -y --no-install-recommends git \
 && apt install -y --no-install-recommends libfontconfig
 
 RUN set -e \
 && apt install -y --no-install-recommends python \
 && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends krb5-config \
 && apt install -y --no-install-recommends libssl-dev

 RUN set -e \
 && apt install -y --no-install-recommends libsasl2-dev \
 && apt install -y --no-install-recommends libsasl2-modules-gssapi-mit \
 && apt install -y --no-install-recommends gcc

 RUN set -e \
 && apt install -y --no-install-recommends libc-dev \
 && apt install -y --no-install-recommends make \
 && apt install -y --no-install-recommends g++ \
 && apt install -y --no-install-recommends build-essential

 RUN set -e \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*
#  && gosu nobody true
#  && set +x

 ### install Kibana

ENV \
 KIBANA_HOME=/opt/kibana \
 KIBANA_PACKAGE=kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz \
 KIBANA_GID=993 \
 KIBANA_UID=993

RUN mkdir ${KIBANA_HOME} \
 && curl -O https://artifacts.elastic.co/downloads/kibana/${KIBANA_PACKAGE} \
 && tar xzf ${KIBANA_PACKAGE} -C ${KIBANA_HOME} --strip-components=1 \
 && rm -f ${KIBANA_PACKAGE} \
 && groupadd -r kibana -g ${KIBANA_GID} \
 && useradd -r -s /usr/sbin/nologin -d ${KIBANA_HOME} -c "Kibana service user" -u ${KIBANA_UID} -g kibana kibana \
 && mkdir -p /var/log/kibana \
 && chown -R kibana:kibana ${KIBANA_HOME} /var/log/kibana

 ###############################################################################
#                              START-UP SCRIPTS
###############################################################################

### Kibana

# ADD ./kibana-init /etc/init.d/kibana
# RUN sed -i -e 's#^KIBANA_HOME=$#KIBANA_HOME='$KIBANA_HOME'#' /etc/init.d/kibana \
#  && chmod +x /etc/init.d/kibana

### NodeJS version 10.15.2 is required for Kibana version 7.4.1.  Delete node distribution included with kibana and replace with manually installed version
RUN set -x \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ] ; then rm -rf /opt/kibana/node \
  && curl -O https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-armv6l.tar.gz \
  && tar -xvf node-v10.15.2-linux-armv6l.tar.gz \
  && mv node-v10.15.2-linux-armv6l /opt/kibana/node ; fi


RUN set -x \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ] ; then git clone --branch v0.25.0 --depth 1 https://github.com/nodegit/nodegit.git \
  && cd /nodegit \
  && wget https://github.com/fg2it/phantomjs-on-raspberry/releases/download/v2.1.1-wheezy-jessie-armv6/phantomjs \
  && export PATH=$PATH:/nodegit:/opt/kibana/node/bin/ \
  && chmod -R 777 /nodegit ; fi
  # && /opt/kibana/node/bin/npm install --unsafe-perm ; fi

# RUN set -x \
#   && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ] ; then mv /opt/kibana/node_modules/@elastic/nodegit/build/Release /opt/kibana/node_modules/@elastic/nodegit/build/Release.old \
#   && mv /opt/kibana/node_modules/@elastic/nodegit/dist/enums.js /opt/kibana/node_modules/@elastic/nodegit/dist/enums.js.old \
#   && cp -rf /nodegit/build/Release /opt/kibana/node_modules/@elastic/nodegit/build \
#   && cp /nodegit/dist/enums.js /opt/kibana/node_modules/@elastic/nodegit/dist ; fi

RUN set -x \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ] ; then cd /nodegit \ 
  && export PATH=$PATH:/nodegit:/opt/kibana/node/bin/ \  
  && /opt/kibana/node/bin/npm install ctags --unsafe-perm ; fi

RUN set -x \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ] ; then mv /opt/kibana/node_modules/@elastic/node-ctags/ctags/build/ctags-node-v64-linux-x64 /opt/kibana/node_modules/@elastic/node-ctags/ctags/build/ctags-node-v64-linux-arm \
  && mv /opt/kibana/node_modules/@elastic/node-ctags/ctags/build/ctags-node-v64-linux-arm/ctags.node /opt/kibana/node_modules/@elastic/node-ctags/ctags/build/ctags-node-v64-linux-arm/ctags.node.old \
  && cp /nodegit/node_modules/ctags/build/Release/ctags.node /opt/kibana/node_modules/@elastic/node-ctags/ctags/build/ctags-node-v64-linux-arm ; fi


USER ${KIBANA_UID}

# RUN cd /root && curl -O https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-armv6l.tar.gz && tar -xvf node-v10.15.2-linux-armv6l.tar.gz
# ADD ./kibana.sh /opt/kibana/bin/kibana
WORKDIR /opt/kibana
RUN chmod a+x /opt/kibana/bin/kibana
CMD ["/opt/kibana/bin/kibana"]