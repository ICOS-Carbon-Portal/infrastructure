import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

// https://nebula.defined.net/docs/guides/rotating-certificate-authority/
export default [
  {
    name: "Copy Certificate Authority",
    copy: {
      src: V.nebula_cert_copy,
      dest: tmpl`${V.nebula_etc_dir}/ca.crt`,
    },
    notify: "reload nebula",
  },
] satisfies TaskFile;
