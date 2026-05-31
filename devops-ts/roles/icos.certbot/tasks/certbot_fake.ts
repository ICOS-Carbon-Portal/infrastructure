import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    include_vars: tmpl("vars/{{ ansible_distribution | lower }}.yml"),
  },
  {
    name: "Create self-signed certificate",
    command:
      tmpl`openssl req -x509 -nodes -subj '/CN=${V.certbot_fake_cn}' -days 365 -newkey rsa:4096 -sha256 -keyout ${V.certbot_fake_key} -out ${V.certbot_fake_crt}\n`,
    args: {
      creates: V.certbot_fake_crt,
    },
  },
  {
    name: "Create nginx config string",
    set_fact: {
      certbot_nginx_conf: `ssl_certificate {{ certbot_fake_crt }};
ssl_certificate_key {{ certbot_fake_key}};
`,
    },
  },
] satisfies TaskFile;
