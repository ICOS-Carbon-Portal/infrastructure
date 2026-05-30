import { type TaskFile } from "../../../lib/ansible.ts";

// https://nebula.defined.net/docs/guides/rotating-certificate-authority/
export default [
  {
    name: "Copy Certificate Authority",
    copy: {
      src: "{{ nebula_cert_copy }}",
      dest: "{{ nebula_etc_dir }}/ca.crt",
    },
    notify: "reload nebula",
  },
] satisfies TaskFile;
