import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";
import { register } from "../lib/register.ts";
import { V } from "../lib/vars.ts";

const _lxd = register("_lxd");

export default [
  {
    hosts: "fsicos2",
    vars: {
      rspamd_domain: "rspamd.icos-cp.eu",
      rspamd_user_file: "/etc/nginx/auth/rspamd",
      rspamd_admin_password: V.vault_rspamd_admin_password,
    },
    pre_tasks: [
      {
        name: "Create rspamd storage pool",
        tags: "pool",
        shell:
          "/snap/bin/lxc storage show rspamd > /dev/null 2>&1 || /snap/bin/lxc storage create rspamd btrfs size=50GB",
        register: "_r",
        changed_when: ['"Storage pool rspamd created" in _r.stdout'],
      },
      {
        name: "Create the rspamd container",
        lxd_container: {
          name: "rspamd",
          state: "started",
          profiles: ["default", "ssh_root"],
          source: {
            type: "image",
            mode: "pull",
            server: "https://cloud-images.ubuntu.com/releases",
            protocol: "simplestreams",
            alias: "22.04",
          },
          devices: {
            root: {
              path: "/",
              type: "disk",
              pool: "rspamd",
              size: "50GB",
            },
          },
          wait_for_ipv4_addresses: true,
          timeout: 600,
        },
        register: _lxd,
      },
    ],
    roles: [
      role("icos.lxd_forward", {
        lxd_forward_ip: _lxd.addresses.eth0.ref.first(),
        lxd_forward_name: "rspamd",
      }),
      role("icos.certbot2", {
        certbot_name: "rspamd",
        certbot_domains: [V.rspamd_domain],
      }).tags("cert"),
      role("icos.nginxsite", {
        nginxsite_name: "rspamd",
        nginxsite_file: "files/rspamd.conf",
        nginxsite_users: [
          {
            username: "secret",
            password: V.rspamd_admin_password,
          },
        ],
      }).tags("nginx"),
    ],
    tasks: [
      {
        name: "Configure postfix to use rspamd as a milter",
        tags: "postconf",
        postconf: {
          param: "smtpd_milters",
          value: "inet:rspamd.lxd:11332",
          reload: true,
          append: true,
        },
      },
    ],
  },
  {
    hosts: "rspamd",
    vars: {
      rspamd_admin_password_hashed: V.vault_rspamd_admin_password_hashed,
    },
    roles: [
      role("icos.lxd_guest").tags("guest"),
      role("icos.rspamd").tags("rspamd"),
    ],
  },
] satisfies Playbook;
