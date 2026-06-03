import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  { import_tasks: "assert_installed.yml" },
  {
    name: "Check that the metrics endpoint responds",
    uri: {
      url: tmpl`http://${V.fsd_target}/${V.fsd_path.default("/metrics")}`,
    },
    retries: 3,
  },
  {
    name: "Install scrape config",
    copy: {
      dest: tmpl`${V.vmagent_fsd}/${V.fsd_name}.yaml`,
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
