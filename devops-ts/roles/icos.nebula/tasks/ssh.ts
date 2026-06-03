import { register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _slurp = register("_slurp");

export default [
  {
    name: "Generate admin ssh key",
    command: `ssh-keygen -q -t ed25519
  -f {{ nebula_ssh_key }}
  -C "nebula admin on {{ nebula_hostname }}" -N ""`,
    args: { creates: tmpl`${V.nebula_etc_dir}/admin` },
  },
  {
    name: "Slurp nebula_ssh_public",
    slurp: { src: tmpl`${V.nebula_ssh_key}.pub` },
    register: _slurp,
  },
  {
    name: "Decode nebula_ssh_public",
    set_fact: {
      nebula_ssh_public: _slurp.content.ref.b64decode(),
    },
  },
] satisfies TaskFile;
