FROM influxdb:1.2.0-alpine
COPY influxdb.conf /etc/influxdb/influxdb.conf
ENTRYPOINT ["/entrypoint.sh"]
CMD ["influxd"]
