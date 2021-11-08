# Prometheus monitoring stack

This role will install a docker-based Prometheus stack.

The stack has five separate parts, running in five different containers:
1. prometheus - collects metrics
2. grafana - displays metrics
3. pushgateway - receives metrics
4. alertmanager - sends out alerts


## Promethus

The prometheus container will scrape remote targets for metrics and store it in
its tsdb datbase

+ [Configuration options](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
+ [Docker images](https://hub.docker.com/r/prom/prometheus)
+ [Dockerfile](https://github.com/prometheus/prometheus/blob/master/Dockerfile)
+ Display help
  > $ docker run --rm -it prom/prometheus --help

## Grafana

Presents a web interface were one can design dashboards to display
metrics. Reads metrics from prometheus.

+ [Official Docs](https://grafana.com/docs/grafana/latest/)
+ [Official Docker instructions](https://grafana.com/docs/grafana/latest/installation/docker/)
+ [Dockerfiles used for the official images](https://github.com/grafana/grafana/tree/master/packaging/docker)


## Pushgateway

Prometheus default way of collecting metrics is to pull it from remote targets. Pushgateway instead receives metrics by way of push and sends them on to prometheus.


## Alertmanager

Sends alerts through email, slack etc.
https://prometheus.io/docs/alerting/alertmanager/

Reloading config.
"Alertmanager can reload its configuration at runtime. If the new configuration
is not well-formed, the changes will not be applied and an error is logged. A
configuration reload is triggered by sending a SIGHUP to the process or sending
a HTTP POST request to the /-/reload endpoint."


## Blackbox exporter

https://github.com/prometheus/blackbox_exporter

+ Probes using HTTP, ICMP etc.
+ Blackbox defines the probes, but not the actual targets (hosts), those are
  then supplied by prometheus.

Reloading config: "Blackbox exporter can reload its configuration file at
runtime. If the new configuration is not well-formed, the changes will not be
applied. A configuration reload is triggered by sending a SIGHUP to the
Blackbox exporter process or by sending a HTTP POST request to the /-/reload
endpoint."
