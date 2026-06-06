import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.lxd_vm", {
        lxd_vm_name: "build",
        lxd_vm_docker: true,
      }),
    ],
  },
  {
    hosts: "build",
    roles: [
      role("icos.lxd_guest").tags("guest"),
    ],
  },
  {
    hosts: "build",
    tags: "setup",
    roles: [
      role("icos.docker").tags("docker"),
    ],
    vars: {
      sbt_openjdk_version: 11,
    },
    tasks: [
      {
        name: "Add the scala-sbt.org key",
        "ansible.builtin.apt_key": {
          keyserver: "keyserver.ubuntu.com",
          id: "2EE0EA64E40A89B84B2DF73499E82A75642AC823",
        },
      },
      {
        name: "Add scalasbt apt repository",
        apt_repository: {
          filename: "scalasbt",
          repo: "deb https://repo.scala-sbt.org/scalasbt/debian all main\n",
        },
      },
      // https://www.scala-sbt.org/1.x/docs/Installing-sbt-on-Linux.html
      {
        name: "Install sbt and openjdk",
        apt: {
          name: [
            "openjdk-11-jdk-headless",
            "sbt",
          ],
        },
      },
      {
        name: "Create build user",
        user: {
          name: "build",
          shell: "/bin/bash",
        },
      },
      // https://github.com/nodesource/distributions#deb
      {
        name: "Add nodesource apt repo",
        "ansible.builtin.shell":
          "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -\n",
        args: {
          creates: "/etc/apt/sources.list.d/nodesource.list",
        },
        changed_when: false,
      },
      {
        name: "Install nodejs",
        apt: {
          update_cache: true,
          name: [
            "nodejs",
          ],
        },
      },
    ],
  },
] satisfies Playbook;
