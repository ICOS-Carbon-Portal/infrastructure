import { expr, type Playbook, role, tmpl } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    vars: {
      wordpress_domains: [
        "www.ingos-infrastructure.eu",
        "eric-forum.eu",
        "www.eric-forum.eu",
        "www.icos-summerschool.eu",
        "www.envriplus.eu",
        "ggmt2022.online",
        "www.ggmt2022.online",
        "avengers-project.eu",
        "www.avengers-project.eu",
        "george-project.eu",
        "www.george-project.eu",
        "kadi-project.eu",
        "www.kadi-project.eu",
      ],
    },
    roles: [
      role("icos.lxd_vm", {
        lxd_vm_name: "wordpress",
        lxd_vm_root_size: "500GB",
        lxd_vm_config: {
          "limits.cpu": "4",
          "limits.memory": "8GB",
        },
      }).tags("lxd"),

      role("icos.certbot2", {
        certbot_name: "wordpress",
        certbot_domains: expr("wordpress_domains"),
      }).tags("cert"),

      role("icos.nginxsite", {
        nginxsite_name: "wordpress",
        nginxsite_file: "files/wordpress.conf",
      }).tags("nginx"),
    ],
  },
  {
    hosts: "wordpress",
    roles: [
      role("icos.lxd_guest").tags("guest"),
    ],
    tasks: [
      {
        name: "Print wp-config warning",
        debug: {
          msg:
            `# Don't forget to add the following in your wp-config.php, after the
# WP_DEBUG line. Otherwise you'll get redirect loops.
if ( $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' )
{
    $_SERVER['HTTPS']       = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}
`,
        },
      },
    ],
  },
] satisfies Playbook;
