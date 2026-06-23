This is geoip, an HTTP-based wrapper for the IP2Location LITE free
IP geolocation database. It takes an IP number as input and responds
with longitude, latitude, and other geographical information.

The different versions of the IP2Location LITE database, which contain
different sets of geographical parameters, can be downloaded at
https://lite.ip2location.com/ip2location-lite.

Note that requests to geoip.icos-cp.eu are 1) https only 2) restricted by the
following nginx config:
  {{ geoip_nginx_allow_deny | indent(2) }}

Please see the Makefile for more info.
