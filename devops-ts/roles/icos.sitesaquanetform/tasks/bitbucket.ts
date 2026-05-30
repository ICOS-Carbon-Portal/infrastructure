import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

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
    register: "bitbucket_known_hosts",
    failed_when: false,
    changed_when: false,
  },
  {
    name: "Update bitbucket known hosts",
    known_hosts: {
      name: "bitbucket.org",
      key:
        "{{ lookup('pipe', 'ssh-keyscan bitbucket.org, `dig +short bitbucket.org`') }}",
    },
    when: raw('bitbucket_known_hosts.stdout == ""'),
  },
] satisfies TaskFile;
