import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  { import_tasks: "assert_installed.yml" },
  {
    name: "Check that the metrics endpoint responds",
    uri: {
      url: tmpl`http://${expr("fsd_target")}/${
        expr("fsd_path | default('/metrics')")
      }`,
    },
    retries: 3,
  },
  {
    name: "Install scrape config",
    copy: {
      dest: tmpl`${V.vmagent_fsd}/${expr("fsd_name")}.yaml`,
      content: `# {{ fsd_name }}
- targets:
  - {{ fsd_target }}
  labels:
    {% if fsd_path is defined %}
    __metrics_path__: "{{ fsd_path }}"
    {%- endif %}
    host: {{ fsd_host }}
`,
    },
  },
] satisfies TaskFile;
