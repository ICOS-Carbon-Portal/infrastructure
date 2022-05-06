Set up a wireguard star topology (i.e a central server). Also known as
hub-and-spoke topology.

This role is requires that the host has wireguard installed, e.g by using the
icos.wireguard role.

It uses a single dict to configure all the hosts. One of the hosts is marked as
"hub" and is the central server which accepts connections from the other hosts.

Configuration looks likes:

    wg_hub_config:
      name: icos1
      allowed_ips: 172.30.1.0/24
      hub:
        addr: icos1.gis.lu.se
        port: 60800
      peers:
        icos1.gis.lu.se:
          name: icos1
          addr: 172.30.1.1
        fsicos2.lunarc.lu.se:
          name: fsicos2
          addr: 172.30.1.2
        fsicos3.lunarc.lu.se:
          name: fsicos3
          addr: 172.30.1.3


* The name of the wireguard interface will be ```wg-icos1```
* All icos1.gis.lu.se is the hub, all other peers are spokes and will connect
  to the hub
* ```/etc/hosts`` will be populated with names such as ```fsicos2.wg-icos1``` which resolves to the wireguard ip addresses.
