import { eq, register, type TaskFile } from "../../../lib/ansible.ts";

const bitbucket_known_hosts = register("bitbucket_known_hosts");
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create ssh directory",
    file: { path: tmpl`${V.project_dir}/.ssh`, state: "directory" },
  },
  {
    name: "Copy SSH public key",
    copy: {
      src: "id_rsa.pub",
      dest: tmpl`${V.project_dir}/.ssh/`,
      mode: 0o644,
    },
  },
  {
    name: "Copy SSH private key",
    copy: { src: "id_rsa", dest: tmpl`${V.project_dir}/.ssh/`, mode: 0o600 },
  },
  {
    name: "Check if known_hosts contains bitbucket",
    command: "ssh-keygen -F bitbucket.org",
    register: bitbucket_known_hosts,
    failed_when: false,
    changed_when: false,
  },
  {
    name: "Update bitbucket known hosts",
    known_hosts: {
      name: "bitbucket.org",
      key: expr(
        "lookup('pipe', 'ssh-keyscan bitbucket.org, `dig +short bitbucket.org`')",
      ),
    },
    when: eq(bitbucket_known_hosts.stdout, ""),
  },
] satisfies TaskFile;
