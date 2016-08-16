FROM qnib/alpn-jre8

ARG GRAFANA_VER=3.1.1-1470047149
RUN apk add --update openssl \
 && wget -qO - https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAFANA_VER}.linux-x64.tar.gz |tar xfz - -C /opt/ \
 && mv /opt/grafana-${GRAFANA_VER} /opt/grafana3
ADD etc/supervisord.d/grafana.ini /etc/supervisord.d/
ADD etc/grafana/grafana.ini /etc/grafana/grafana.ini.new
ADD var/lib/grafana/grafana.db /var/lib/grafana/
ADD etc/consul.d/grafana3.json /etc/consul.d/
ADD opt/qnib/grafana3/bin/start.sh /opt/qnib/grafana3/bin/
ADD opt/qnib/grafana3/dashboards/docker-stats.json \
    /opt/qnib/grafana3/dashboards/
