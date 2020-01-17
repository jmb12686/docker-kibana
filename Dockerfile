FROM ubuntu

ARG KIBANA_VERSION=7.4.1

###############################################################################
#                                INSTALLATION
###############################################################################

### install prerequisites (cURL, gosu, tzdata)

RUN set -x \
 && apt update -qq \
 && apt install -qqy --no-install-recommends ca-certificates curl gosu tzdata wget \
 && curl -sL https://deb.nodesource.com/setup_10.x | bash \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && gosu nobody true \
 && set +x

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
USER ${KIBANA_UID}


# ADD ./kibana-init /etc/init.d/kibana
# RUN sed -i -e 's#^KIBANA_HOME=$#KIBANA_HOME='$KIBANA_HOME'#' /etc/init.d/kibana \
#  && chmod +x /etc/init.d/kibana

#  #### NodeJS for Kibana overwrite embedded node with node version installed thru apt
RUN which node \
  && NODE_PATH=$(which node) \
  && echo "NODE_PATH=$NODE_PATH" \
  && ln -sf $NODE_PATH /opt/kibana/node/bin/node


# RUN cd /root && curl -O https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-armv6l.tar.gz && tar -xvf node-v10.15.2-linux-armv6l.tar.gz
# ADD ./kibana.sh /opt/kibana/bin/kibana
RUN chmod a+x /opt/kibana/bin/kibana
CMD ["/opt/kibana/bin/kibana"]