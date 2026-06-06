import { jbuild_rrsync_bin, jbuild_rsync_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Install rsync",
    apt: {
      name: ["rsync"],
    },
  },
  {
    name: "Add keys to authorized_keys",
    authorized_key: {
      user: jbuild_rsync_user,
      key_options: tmpl`command="${jbuild_rrsync_bin} /project/common"`,
      key: `{% for elt in _jbuild_user_keys.results -%}
{{ elt.public_key }}
{% endfor %}
`,
    },
  },
] satisfies TaskFile;
