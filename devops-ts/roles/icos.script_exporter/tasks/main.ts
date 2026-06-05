import { iff, lookup, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _sysd = register("_sysd");

export default [
  {
    name: "Download script_exporter",
    include_role: {
      name: "icos.github_download_bin",
    },
    vars: {
      dbin_user: "ricoberger",
      dbin_repo: "script_exporter",
      dbin_url:
        tmpl`${V.dbin__down}/v${V.dbin__vers}/script_exporter-linux-${V.sexp_arch}`,
      dbin_download_dest:
        tmpl`${V.dbin_download_base}/script-exporter-${V.dbin__vers}`,
      dbin_unar: false,
    },
  },
  {
    name: "Create script_exporter home directory",
    file: {
      path: V.sexp_home,
      state: "directory",
    },
  },
  {
    name: "Add base config for script-exporter",
    blockinfile: {
      marker: "# {mark} base config",
      create: true,
      insertafter: "BOF",
      path: V.sexp_config_file,
      block: lookup("template", "config.yaml"),
    },
    notify: "reload script-exporter",
  },
  { import_tasks: "scripts.yml" },
  {
    name: "Copy script-exporter systemd files",
    template: {
      dest: "/etc/systemd/system/",
      src: "script-exporter.service",
    },
    register: _sysd,
  },
  {
    name: "Start/restart script-exporter.service",
    systemd: {
      "daemon-reload": iff(_sysd.changed, "yes", "no"),
      name: "script-exporter.service",
      enabled: true,
      state: "started",
    },
  },
  {
    name: "Add ourselves to the local vmagent installation",
    include_role: {
      name: "icos.vmagent",
      tasks_from: "add_config",
    },
    vars: {
      vmagent_config_dest: "script-exporter-scripts.yaml",
      vmagent_config_content:
        `# These are the scripts exported by script-exporter.
- job_name: script-exporter
  http_sd_configs:
    - url: http://localhost:9469/discovery
  relabel_configs:
    - target_label: instance
      replacement: {{ inventory_hostname_short }}
`,
    },
  },
] satisfies TaskFile;
