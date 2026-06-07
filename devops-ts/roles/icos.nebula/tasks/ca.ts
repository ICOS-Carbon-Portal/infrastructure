import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { nebula_cert_copy } from "../../../lib/globals.ts";
import { tmpl } from "../../../lib/template.ts";

// https://nebula.defined.net/docs/guides/rotating-certificate-authority/
export default [
  {
    name: "Copy Certificate Authority",
    copy: {
      src: nebula_cert_copy,
      dest: tmpl`${V.nebula_etc_dir}/ca.crt`,
    },
    notify: "reload nebula",
  },
] satisfies TaskFile;
