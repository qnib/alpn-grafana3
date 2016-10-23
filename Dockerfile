FROM qnib/alpn-jre8

ARG GRAFANA_VER=3.1.1-1470047149
ENV GRAFANA_DATA_SOURCES=qcollect,prometheus

RUN apk --no-cache add sqlite openssl curl \
 && wget -qO - https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAFANA_VER}.linux-x64.tar.gz |tar xfz - -C /opt/ \
 && mv /opt/grafana-${GRAFANA_VER} /opt/grafana
ADD etc/supervisord.d/grafana.ini /etc/supervisord.d/
ADD etc/grafana/grafana.ini /etc/grafana/grafana.ini
ADD etc/consul.d/grafana.json /etc/consul.d/
ADD opt/qnib/grafana/bin/start.sh \
    opt/qnib/grafana/bin/healthcheck.sh \
    /opt/qnib/grafana/bin/
## SQL dumps to setup /var/lib/grafana/grafana.db
ADD opt/qnib/grafana/sql/00-migration_log.sql \
    opt/qnib/grafana/sql/10-user.sql \
    opt/qnib/grafana/sql/20-init-dash.sql \
    opt/qnib/grafana/sql/30-data-source.sql \
    opt/qnib/grafana/sql/40-backend.sql \
    /opt/qnib/grafana/sql/
ADD opt/qnib/grafana/sql/data-sources/prometheus.sql \
    opt/qnib/grafana/sql/data-sources/qcollect.sql \
    /opt/qnib/grafana/sql/data-sources/
ADD opt/qnib/grafana/sql/dashboards/docker-stats.sql \
    opt/qnib/grafana/sql/dashboards/prometheus.sql \
    /opt/qnib/grafana/sql/dashboards/
