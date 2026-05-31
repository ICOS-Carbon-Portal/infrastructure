import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create new repo file",
    copy: {
      dest: V.bbclient_repo_file,
      content:
        `# Be aware that the "hostnames" in this file are then transformed by the
# ssh config at {{ bbclient_ssh_config }}
{% for br in bbclient_remotes %}
{{ br }}:repos/{{ bbclient_name }}.repo
{% endfor %}
`,
    },
  },
  {
    include_tasks: "single_repo.yml",
    loop: tmpl("{{ bbclient_remotes }}"),
    loop_control: { loop_var: "bbclient_remote" },
  },
  {
    name: "Run bbclient-all info to verify access",
    command: tmpl`${V.bbclient_all} info`,
    environment: {
      BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK: true,
      BORG_RELOCATED_REPO_ACCESS_IS_OK: true,
    },
    changed_when: false,
  },
] satisfies TaskFile;
