// This playbook can be used to:
//   1. Find out which hosts run a specific distribution of ubuntu.
//   2. Dist-upgrade those hosts.
import { type Playbook } from "../lib/ansible/play.ts";
import { iff } from "../lib/template.ts";
import { tmpl, truthy, V } from "../lib/vars.ts";

export default [
  {
    hosts: "all",
    tasks: [
      {
        group_by: {
          key: tmpl`${V.ansible_distribution_release}_hosts`,
        },
      },
    ],
  },

  // 18.04 bionic
  // 20.04 focal
  // 22.04 jammy
  {
    hosts: "focal_hosts",
    tasks: [
      { debug: "var=inventory_hostname" },
      { debug: "var=docker_prevent_upgrade" },
    ],
  },

  {
    hosts: "focal_hosts",
    tasks: [
      {
        name: "Make sure docker is upgraded",
        dpkg_selections: {
          name: V.item,
          selection: "install",
        },
        loop: ["docker.io", "containerd"],
      },
      {
        name: "upgrade everything",
        apt: {
          update_cache: true,
          upgrade: "full",
        },
      },
      {
        name: "reboot",
        reboot: null,
      },
      // For some reason, one of the VMs did not have do-release-upgrade
      {
        name: "Install ubuntu-release-upgrader-core",
        apt: {
          name: ["ubuntu-release-upgrader-core"],
        },
      },
      {
        name: "release upgrade",
        command: "do-release-upgrade -f DistUpgradeViewNonInteractive",
      },
      {
        name: "reboot",
        reboot: null,
      },
    ],
  },

  {
    hosts: "jammy_hosts",
    tasks: [
      {
        name: "Make sure docker isn't upgraded",
        dpkg_selections: {
          name: V.item,
          selection: iff(
            truthy(V.docker_prevent_upgrade).default(false),
            "hold",
            "install",
          ),
        },
        loop: ["docker.io", "containerd"],
      },
    ],
  },
] satisfies Playbook;
