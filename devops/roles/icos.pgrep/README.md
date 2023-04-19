## To test the prometheus_metrics container

    wget -qO- localhost:9187/metrics

That will connect to the exposed port and retrieve metrics. It's not until one
request metrics that the exporter will try to connect to postgres (and thus
trigger any connection errors).
