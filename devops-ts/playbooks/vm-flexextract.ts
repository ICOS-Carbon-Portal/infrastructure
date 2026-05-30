import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.lxd_vm", {
        name: "Create the flexextract VM",
        lxd_vm_name: "flexextract",
        lxd_vm_docker: true,
        lxd_vm_config: {
          "limits.cpu": "14",
          "limits.memory": "55GB",
        },
        lxd_vm_devices: {
          flexextract: {
            path: "/data/flexextract",
            source: "/disk/data/flexextract",
            type: "disk",
            recursive: "true",
          },
          flexextract_meteo: {
            path: "/data/flexextract/meteo",
            source: "/nfs/flexextract_meteo",
            type: "disk",
          },
          flexpart_output: {
            path: "/data/flexpart/output",
            source: "/data/flexpart/output",
            type: "disk",
            readonly: "False",
          },
        },
      }).tags("vm"),

      role("icos.certbot2", {
        certbot_name: "flexextract",
        certbot_domains: ["flexextract.icos-cp.eu"],
      }).tags("cert"),

      role("icos.nginxsite", {
        nginxsite_name: "flexextract",
        nginxsite_file: "files/flexextract.conf",
      }).tags("nginx"),
    ],
  },
  {
    hosts: "flexextract",
    roles: [
      role("icos.lxd_guest").tags("guest"),

      role("icos.docker").tags("docker"),

      role("icos.flexextract", {
        flexextract_src_dir: "/tmp/docker_flexextract_7.1.0",
        flexextract_download_host: "/disk/data/flexextract_download",
      }).tags("flexextract"),

      role("icos.sshlogin", {
        sshlogin_dst: "flexpart",
        sshlogin_src_user: "root",
        sshlogin_dst_user: "ubuntu",
      }).tags("sshlogin"),
    ],
  },
] satisfies Playbook;
