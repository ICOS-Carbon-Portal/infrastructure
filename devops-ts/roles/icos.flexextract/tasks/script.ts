import { flexextract_bin_dir } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: tmpl`Create ${flexextract_bin_dir} directory`,
    file: {
      path: flexextract_bin_dir,
      state: "directory",
    },
  },
  {
    name: "Copy flexextract script",
    copy: {
      src: "flexextract.sh",
      dest: tmpl`${flexextract_bin_dir}/`,
      mode: "-x",
    },
    register: "_script",
  },
  {
    name: "Create flexextract wrapper",
    copy: {
      dest: tmpl`${flexextract_bin_dir}/flexextract`,
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
