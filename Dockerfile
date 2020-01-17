FROM ubuntu

ARG KIBANA_VERSION=7.4.1

###############################################################################
#                                INSTALLATION
###############################################################################

### install prerequisites (cURL, gosu)


RUN set -x \
 && apt update -qq \
 && apt install -qqy --no-install-recommends ca-certificates curl gosu wget \
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

# ADD ./kibana-init /etc/init.d/kibana
# RUN sed -i -e 's#^KIBANA_HOME=$#KIBANA_HOME='$KIBANA_HOME'#' /etc/init.d/kibana \
#  && chmod +x /etc/init.d/kibana

### NodeJS version 10.15.2 is required for Kibana version 7.4.1.  Delete node distribution included with kibana and replace with manually installed version
RUN set -x \
  && rm -rf /opt/kibana/node \
  && curl -O https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-armv6l.tar.gz \
  && tar -xvf node-v10.15.2-linux-armv6l.tar.gz \
  && mv node-v10.15.2-linux-armv6l /opt/kibana/node

USER ${KIBANA_UID}

# RUN cd /root && curl -O https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-armv6l.tar.gz && tar -xvf node-v10.15.2-linux-armv6l.tar.gz
# ADD ./kibana.sh /opt/kibana/bin/kibana
RUN chmod a+x /opt/kibana/bin/kibana
CMD ["/opt/kibana/bin/kibana"]