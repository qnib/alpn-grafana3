FROM qnib/alpn-jre8

ARG GRAFANA_VER=3.1.1-1470047149
RUN apk add --update openssl \
 && wget -qO - https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAFANA_VER}.linux-x64.tar.gz |tar xfz - -C /opt/ \
 && mv /opt/grafana-${GRAFANA_VER} /opt/grafana3
