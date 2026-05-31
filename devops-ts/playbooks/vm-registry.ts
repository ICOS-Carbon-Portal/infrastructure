import { expr, type Playbook, role, V } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos3",
    vars: {
      registry_domain: "registry.icos-cp.eu",
    },
    pre_tasks: [
      {
        name: "Create storage for registry volumes",
        zfs: {
          name: "pool/registry",
          state: "present",
          extra_zfs_properties: {
            quota: "500G",
          },
        },
      },
      {
        name: "Change owner of /pool/registry",
        file: {
          path: "/pool/registry",
          owner: 1000000,
          group: 1000000,
        },
      },
      {
        name: "Create the registry container",
        lxd_container: {
          name: "registry",
          state: "started",
          profiles: ["default", "ssh_root"],
          source: {
            type: "image",
            mode: "pull",
            server: "https://cloud-images.ubuntu.com/releases",
            protocol: "simplestreams",
            alias: "20.04",
          },
          devices: {
            registry: {
              path: "/docker/registry/volumes/registry",
              source: "/pool/registry",
              type: "disk",
            },
            root: {
              path: "/",
              pool: "default",
              type: "disk",
              size: "50GB",
            },
          },
          config: {
            "limits.memory": "8GB",
            "security.nesting": "true",
          },
          wait_for_ipv4_addresses: true,
          wait_for_ipv4_interfaces: "eth0",
          timeout: 60,
        },
        register: "_lxd",
      },
    ],
    roles: [
      role("icos.lxd_forward", {
        lxd_forward_ip: expr("_lxd.addresses.eth0 | first"),
        lxd_forward_name: "registry",
      }),

      role("icos.certbot2", {
        certbot_name: "registry",
        certbot_domains: [V.registry_domain],
      }).tags(["cert", "registry"]),

      role("icos.nginxsite", {
        nginxsite_name: "registry",
        nginxsite_file: "roles/icos.registry/templates/registry-nginx.conf",
        registry_host: "registry.lxd",
        registry_cert: "registry",
        registry_allow: expr("vault_nginx_allow_internal_only"),
      }).tags(["registry", "nginx"]),
    ],
  },
  {
    hosts: "registry",
    vars: {
      registry_domain: "registry.icos-cp.eu",
    },
    roles: [
      role("icos.lxd_guest").tags("guest"),

      role("icos.docker2").tags("docker"),

      role("icos.registry", {
        registry_users: expr("vault_registry_users"),
      }).tags("registry"),
    ],
    tasks: [
      {
        name: "Login to registry",
        "community.general.docker_login": {
          registry_url: V.registry_domain,
          username: "docker",
          password: expr("vault_registry_pass"),
        },
      },
    ],
  },
] satisfies Playbook;
