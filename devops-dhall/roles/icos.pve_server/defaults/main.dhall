-- Auto-generated from ../../../../devops/roles/icos.pve_server/defaults/main.yml

{
    pve_dnat_bridge = "vmbr0"
  , pve_dnat_leases = "/var/lib/misc/dnsmasq.{{ pve_dnat_bridge }}.leases"
}
