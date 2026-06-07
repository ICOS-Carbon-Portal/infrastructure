import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { conmon_local_version } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { not, truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Retrieve version of installed conmon (if any)",
    check_mode: false,
    shellfact: {
      // "conmon version 2.0.9\ncommit: unknown"
      exec: `for f in /usr/bin/conmon\\
         /usr/local/libexec/podman/conmon\\
         /usr/libexec/podman/conmon; do
  if [ -e $f ]; then
    $f --version | awk 'NR == 1 { print $3 }';
    break
  fi
done
`,
      fact: "conmon_local_version",
    },
  },
  {
    name: "Is installed version of conmon sufficient?",
    debug: {
      msg: tmpl`Version (${conmon_local_version}) is sufficient`,
    },
    when: truthy(V.conmon_local_version_ok),
  },
  // Otherwise, attempt to install by using apt.
  {
    import_tasks: "apt_install.yml",
    when: not(V.conmon_local_version_ok),
  },
  // Finally, fall back to downloading and installing.
  {
    import_tasks: "download_install.yml",
    when: [
      not(V.conmon_local_version_ok),
      not(V.conmon_apt_version_ok),
    ],
  },
] satisfies TaskFile;
