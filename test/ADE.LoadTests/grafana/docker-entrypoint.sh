#!/bin/bash

# set sensible defaults if not provided by docker run
: "${GF_SECURITY_ADMIN_USER:=admin}"
: "${GF_SECURITY_ADMIN_PASSWORD:=admin}"

# Variables
GRAFANA_BASIC_AUTH="${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}"
GRAFANA_URL="localhost:3000"
GRAFANA_SOURCES_PATH="/etc/grafana"

function kill_container {
    # Exit with error
    exit 1;
}


function bootstrap_grafana {
    # Timeout after 1 min
    local readonly LOOP_TIMEOUT_SECONDS=20
    local readonly LOOP_INCREMENT_SECONDS=3
    local LOOP_COUNT_SECONDS=0

    # Wait until grafana is up
    until $(curl --silent --fail --show-error --output /dev/null -u ${GRAFANA_BASIC_AUTH} http://${GRAFANA_URL}/api/datasources); do
        # If we've tried too many times
        if (( ${LOOP_COUNT_SECONDS} >= ${LOOP_TIMEOUT_SECONDS} )); then
            echo "Error: Server never started."
            kill_container
        fi

        # tick
        printf '.'

        # Increment loop counter
        (( LOOP_COUNT_SECONDS+=1 ))

        sleep ${LOOP_INCREMENT_SECONDS}
    done ;

    # Loop over datasources, and add each via API
    # Currently only using a single Prometheus data source
    for file in $(find ${GRAFANA_SOURCES_PATH}/datasources/ -name '*.json') ; do
        if [ -e "$file" ] ; then
            echo "importing datasource: $file" &&
            curl --silent --fail --show-error \
                -u ${GRAFANA_BASIC_AUTH} \
                --request POST http://${GRAFANA_URL}/api/datasources \
                --header "Content-Type: application/json" \
                --data-binary "@$file" ;
            echo "" ;
        fi
    done ;
}

# Turn on monitor mode so we can send job to background
set -m

# Run Grafana's default startup script https://github.com/grafana/grafana-docker
echo "Start Grafana in Background"
/run.sh &

# Bootstrap Grafana with datasources and dashboards
echo "Init Grafana"
bootstrap_grafana

echo "Bring Grafana Back to Foreground"
jobs
fg %1
