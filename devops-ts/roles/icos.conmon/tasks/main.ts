import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, notVar, tmpl } from "../_ctx.ts";

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
      msg: tmpl`Version (${expr("conmon_local_version")}) is sufficient`,
    },
    when: raw("conmon_local_version_ok"),
  },
  // Otherwise, attempt to install by using apt.
  {
    import_tasks: "apt_install.yml",
    when: notVar("conmon_local_version_ok"),
  },
  // Finally, fall back to downloading and installing.
  {
    import_tasks: "download_install.yml",
    when: [
      notVar("conmon_local_version_ok"),
      notVar("conmon_apt_version_ok"),
    ],
  },
] satisfies TaskFile;
