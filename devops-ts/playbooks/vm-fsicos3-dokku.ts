import { type Playbook, role, tmpl } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos3",
    vars: {
      dokku_wildcard_domains: ["*.app.icos-cp.eu"],
      dokku_static_domains: ["curve.icos-ri.eu"],
      dokku_redirect_domains: ["curve.icos-cp.eu"],
    },
    roles: [
      role("icos.lxd_vm", {
        name: "Create the dokku VM",
        lxd_vm_name: "dokku",
        lxd_vm_docker: true,
        lxd_vm_docker_size: "200GB",
        lxd_vm_root_size: "500GB",
        lxd_vm_config: {
          "limits.cpu": "8",
          "limits.memory": "64GB",
        },
        lxd_vm_ubuntu_version: "24.04",
      }),

      role("icos.certbot2", {
        certbot_name: "dokku",
        certbot_domains: tmpl(
          "{{ (dokku_static_domains + dokku_redirect_domains) }}",
        ),
      }).tags("cert"),

      role("icos.nginxsite", {
        nginxsite_name: "dokku",
        nginxsite_file: "templates/dokku-nginx.conf",
        dokku_proxy_host: "dokku.lxd",
        dokku_proxy_port: 80,
      }).tags("nginx"),
    ],
    tasks: [
      {
        name: "Add LXD disk device for dokku",
        tags: "dokku_add_device",
        command:
          "lxc config device add dokku flexpart disk source=/data/cupcake path=/data/flexpart/output shift=true\n",
      },
    ],
  },

  {
    hosts: "dokku",
    roles: [
      role("icos.lxd_guest").tags("guest"),
      role("icos.docker2").tags("docker"),
      role("icos.dokku").tags("dokku"),
    ],
  },
] satisfies Playbook;
