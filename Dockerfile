# This Dockerfile was generated from templates/Dockerfile.j2
#FROM centos:7
FROM alpine
LABEL maintainer "Elastic Docker Team <docker@elastic.co>"
EXPOSE 5601
ENV KIBANA_VERSION 5.3.1
ENV BASE /usr/share/kibana
# Add Reporting dependencies.
#RUN yum update -y && yum install -y fontconfig freetype && yum clean all


WORKDIR $BASE
RUN apk add --no-cache --update bash ca-certificates su-exec util-linux curl && \
    apk add nodejs && \
    curl -Ls https://artifacts.elastic.co/downloads/kibana/kibana-$KIBANA_VERSION-linux-x86_64.tar.gz | tar --strip-components=1 -zxf - && \
    mkdir -p /opt/kibana && \
    rm -rf node && \
    ln -sf /usr/bin/node $BASE/node && \
    ln -sf $BASE/* /opt/kibana && \
    # Provide a non-root user to run the process.
    addgroup -g 1000 kibana && \
    adduser -SDH -u 1000 -G kibana -h /usr/share/kibana kibana && \
    chown -R kibana:kibana /usr/share/kibana /opt/kibana && \
    apk del curl && \
    rm -rf /var/cache/apk/*

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/kibana/bin:$PATH

RUN kibana-plugin install x-pack
# Set some Kibana configuration defaults.
ADD config/kibana.yml /usr/share/kibana/config/

# Add the launcher/wrapper script. It knows how to interpret environment
# variables and translate them to Kibana CLI options.
ADD bin/kibana-docker /usr/local/bin/

# Add a self-signed SSL certificate for use in examples.
ADD ssl/kibana.example.org.* /usr/share/kibana/config/

#USER kibana

CMD /usr/local/bin/kibana-docker
