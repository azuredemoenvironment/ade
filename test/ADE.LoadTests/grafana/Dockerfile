FROM grafana/grafana:4.6.5
COPY grafana.ini /etc/grafana/grafana.ini
COPY gatling-dashboard.json /var/lib/grafana/dashboards/gatling-dashboard.json
COPY influxdatasource.json  /etc/grafana/datasources/influxdatasource.json
COPY run.sh /run.sh

# Workaround until Grafana 5 - Cannot import datasource as a file !!!
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/docker-entrypoint.sh"]
