import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  // Stiltcluster can be deployed either:
  //   1. from the sbt plugin to all stiltcluster hosts. this way a brand new
  //   stiltcluster.jar file is compiled on localhost and pushed to all hosts.
  //
  //   2. purely from ansible without having access to a local stiltcluster.jar
  //   file. instead the jar file is copied from stiltcluster_fetch_host to the
  //   other hosts in the cluster.
  //
  // Scenario 1 happens when stiltcluster_jar_file is set, otherwise scenario 2.
  {
    name: "Add systemd service",
    template: {
      src: "stiltcluster.service",
      dest: "/etc/systemd/system/stiltcluster.service",
    },
  },
  // scenario 1, we retrieve stiltcluster.jar and set the stiltcluster_jar_file
  // variable temporarily.
  {
    when: [
      raw("inventory_hostname != stiltcluster_fetch_host"),
      raw("stiltcluster_jar_file is undefined"),
    ],
    block: [
      {
        name: "Retrive stiltcluster.jar",
        delegate_to: V.stiltcluster_fetch_host,
        run_once: true,
        fetch: {
          src: V.stiltcluster_fetch_path,
          // the destination is relative to the playbook
          dest: "tmp/stiltcluster.jar",
          // don't append hostname/path/to/file
          flat: true,
        },
      },
      {
        name: "Temporarily set stiltcluster_jar_file",
        set_fact: {
          stiltcluster_jar_file: "tmp/stiltcluster.jar",
          cacheable: false,
        },
      },
    ],
  },
  {
    name: "Copy jarfile",
    when: raw("stiltcluster_jar_file is defined"),
    copy: {
      src: expr("stiltcluster_jar_file"),
      dest: tmpl`${V.stiltcluster_home}/stiltcluster.jar`,
      backup: true,
    },
    notify: "restart stiltcluster",
  },
  {
    name: "Remove all but the five newest of jar file backups",
    "ansible.builtin.shell":
      `ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --
`,
    args: { chdir: V.stiltcluster_home },
    register: "_r",
    changed_when: '_r.stdout.startswith("removed")',
  },
  {
    name: "Make sure stiltcluster is started",
    systemd: {
      name: "stiltcluster.service",
      enabled: true,
      "daemon-reload": true,
      state: "started",
    },
  },
] satisfies TaskFile;
