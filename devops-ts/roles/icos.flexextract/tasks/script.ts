import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl`Create ${V.flexextract_bin_dir} directory`,
    file: {
      path: V.flexextract_bin_dir,
      state: "directory",
    },
  },
  {
    name: "Copy flexextract script",
    copy: {
      src: "flexextract.sh",
      dest: tmpl`${V.flexextract_bin_dir}/`,
      mode: "-x",
    },
    register: "_script",
  },
  {
    name: "Create flexextract wrapper",
    copy: {
      dest: tmpl`${V.flexextract_bin_dir}/flexextract`,
      mode: "+x",
      content: `#!/bin/bash
TAG="{{ flexextract_tag }}"
HOST_DIR="{{ flexextract_download_host }}"
CONT_DIR="{{ flexextract_download_cont }}"
source "{{ _script.dest }}"
`,
    },
  },
] satisfies TaskFile;
