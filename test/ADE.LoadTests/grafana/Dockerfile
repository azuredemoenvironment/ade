FROM grafana/grafana:7.4.3

# Copy configuration
COPY grafana.ini /etc/grafana/
COPY influxdb.yaml /etc/grafana/provisioning/datasources/
COPY gatling.yml /etc/grafana/provisioning/dashboards/

# Copy Dashboard Files
RUN mkdir -p /var/lib/grafana/dashboards
COPY gatling.json /var/lib/grafana/dashboards
