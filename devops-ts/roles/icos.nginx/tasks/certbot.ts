import { nginx_certbot_bin } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  // It used to be pip but these days letsencrypt recommends snap for Ubuntu.
  {
    name: "Install certbot using snap",
    "community.general.snap": {
      name: "certbot",
      classic: true,
    },
  },
  {
    name: "Add job to renew certificates",
    cron: {
      name: "Certbot renewal",
      job: tmpl`${nginx_certbot_bin} renew -q`,
      special_time: "daily",
    },
  },
  {
    name: "Create /etc/letsencrypt/renewal-hooks/deploy directory",
    file: {
      path: "/etc/letsencrypt/renewal-hooks/deploy",
      state: "directory",
    },
  },
  {
    name: "Add a nginx deploy-hook for certbot",
    copy: {
      dest: "/etc/letsencrypt/renewal-hooks/deploy/nginx.sh",
      mode: "+x",
      content: `#!/bin/bash
service nginx reload
`,
    },
  },
  {
    name: "Install the icos-certbot util",
    tags: "certbot_utils",
    import_role: { name: "icos.python_util" },
    vars: {
      python_util_src: "certbot_util",
    },
  },
] satisfies TaskFile;
