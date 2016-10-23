#!/bin/bash

cd /opt/grafana/

DB_PATH=/var/lib/grafana/grafana.db
SQL_PATH=${GRAFANA_SQL_PATH-/opt/qnib/grafana/sql}
mkdir -p /var/lib/grafana
## Common SQL to get started
for db in $(ls ${SQL_PATH} |sort);do
    cat ${SQL_PATH}/${db} | sqlite3 ${DB_PATH}
done
## data sources
if [ "X${GRAFANA_DATA_SOURCES}" != "X" ];then
    for ds in $(echo ${GRAFANA_DATA_SOURCES} |sed -e 's/,/ /g');do
        if [ -f ${SQL_PATH}/data-sources/${ds}.sql ];then
            echo "[INFO] Parse '${SQL_PATH}/data-sources/${ds}.sql'"
            cat ${SQL_PATH}/data-sources/${ds}.sql | sqlite3 /var/lib/grafana/grafana.db
        else
            echo "[ERROR] Could not find '${SQL_PATH}/data-sources/${ds}.sql'"
        fi
    done
fi

### inserts dashboards
DASH_PATH=${GRAFANA_DASH_PATH-/opt/qnib/grafana/dashboards/}
DASH_TIME=$(date +"%F %H:%M:%S")
for dash in $(find ${DASH_PATH} -name \*.json);do
    echo $dash
    DASH_TITLE=$(jq '.title' $dash |sed -e 's/"//g')
    DASH_SLUG=$(echo $dash |awk -F/ '{print $NF}' | sed -e 's/\.json$//')
    DASH_DATA=$(jq -c "." ${dash})
    sqlite3 ${DB_PATH} "INSERT INTO dashboard (created, updated, version, slug, title, org_id, data) VALUES ('${DASH_TIME}', '${DASH_TIME}', '0', '${DASH_SLUG}', '${DASH_TITLE}','1','${DASH_DATA}');"
done

sleep 1
/opt/grafana/bin/grafana-server --pidfile=/var/run/grafana-server.pid --config=/etc/grafana/grafana.ini cfg:default.paths.data=/var/lib/grafana cfg:default.paths.logs=/var/log/grafana
