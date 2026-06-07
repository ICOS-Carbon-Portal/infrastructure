import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { certbot_conf_name, certbot_domains } from "../../../lib/sharedvars.ts";
import { jinjaFor, tmpl } from "../../../lib/template.ts";
import { not } from "../../../lib/vars.ts";

const _conf_file = register("_conf_file");
const _write_conf = register("_write_conf");

export default [
  {
    name: tmpl`Check if ${certbot_conf_name} exists`,
    stat: {
      path: V.certbot_conf_path,
    },
    register: _conf_file,
  },
  {
    name:
      tmpl`Create an initial nginx ${certbot_conf_name} for the certbot certification`,
    copy: {
      dest: V.certbot_conf_path,
      content: `server {
  listen 80;
  server_name {% for domain in certbot_domains %} {{ domain }}{% endfor %};

  location /.well-known {
      root /usr/share/nginx/html;
  }
}
`,
    },
    register: _write_conf,
    when: not(_conf_file.stat.exists),
  },
  {
    name: "Reload nginx",
    service: {
      name: "nginx",
      state: "reloaded",
    },
    when: _write_conf.changed,
  },
  {
    name: "Install SSL certificate",
    command:
      tmpl`${V.certbot_bin} certonly --authenticator nginx --non-interactive ${
        jinjaFor<string>(
          "domain",
          certbot_domains,
          (domain) => tmpl` --domain ${domain} `,
        )
      } --email ${V.certbot_email} --agree-tos --expand\n`,
    register: "o",
    changed_when:
      '"Certificate not yet due for renewal; no action taken." not in o.stdout',
  },
  {
    name: "Set nginx config variable",
    set_fact: {
      certbot_nginx_conf: `ssl_certificate {{ certbot_live_crt }};
ssl_certificate_key {{ certbot_live_key }};
`,
    },
  },
] satisfies TaskFile;
