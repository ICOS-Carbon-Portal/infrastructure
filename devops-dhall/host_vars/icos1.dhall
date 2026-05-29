-- Auto-generated from ../../devops/host_vars/icos1.yml

{
    caddy_modules = [ "github.com/caddyserver/replace-response" ]
  , caddy_global_conf = ''
    {
        order replace after encode
    }

  ''
  , ansible_hostname = "icos1.gis.lu.se"
  , ansible_port = 60022
  , iptables_ssh_port = 60022
  , lxd_vm_variant = "zfs"
  , icosdata_exports = ''
    /pool/flexextract *.nebula(rw)

  ''
}
