-- Auto-generated from ../../devops/host_vars/cdb.yml

{
    caddy_modules = [ "github.com/caddyserver/replace-response" ]
  , caddy_global_conf = ''
    {
        order replace after encode
    }

  ''
  , lxd_vm_variant = "ext4"
}
