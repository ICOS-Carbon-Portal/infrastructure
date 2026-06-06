import {
  node_exporter_allow,
  node_exporter_arch,
  node_exporter_download,
  node_exporter_environ,
  node_exporter_home,
  node_exporter_listen,
  node_exporter_textfiles,
  node_exporter_user,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { iff, tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create node_exporter user",
    user: {
      name: node_exporter_user,
      home: node_exporter_home,
      shell: "/usr/sbin/nologin",
    },
  },
  {
    name: "Download node_exporter",
    include_role: {
      name: "icos.github_download_bin",
    },
    vars: {
      dbin_download_dest: node_exporter_download,
      dbin_user: "prometheus",
      dbin_repo: "node_exporter",
      dbin_path: "node_exporter",
      dbin_arch: node_exporter_arch,
    },
  },
  {
    name: "Create the textfile collector directory",
    file: {
      path: node_exporter_textfiles,
      // Setup this directory in the same way as /tmp, i.e anyone can write to it
      // but not remove other user's files.
      mode: "1777",
      state: "directory",
    },
  },
  {
    name: "Copy node-exporter systemd files",
    template: {
      dest: "/etc/systemd/system/",
      src: item,
    },
    loop: [
      "node-exporter.service",
      "node-exporter.socket",
    ],
    notify: "restart node-exporter",
  },
  {
    name: "Create the EnvironmentFile used by the systemd service",
    copy: {
      dest: node_exporter_environ,
      content:
        tmpl`OPTIONS=--collector.textfile.directory=${node_exporter_textfiles}\n`,
    },
  },
  // node-exporter is socket activated, so enable and start the socket
  {
    name: "Enable and start node-exporter.socket",
    systemd: {
      "daemon-reload": true,
      name: "node-exporter.socket",
      enabled: true,
      state: "started",
    },
  },
  {
    name: "Allow node_exporter through firewall",
    iptables_raw: {
      name: "allow_node_exporter",
      state: iff(node_exporter_allow, "present", "absent"),
      rules: tmpl`-A INPUT -p tcp --dport ${node_exporter_listen} -j ACCEPT`,
    },
  },
] satisfies TaskFile;
