import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { golang_local_version } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { not, truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Retrieve version of installed golang (if any)",
    check_mode: false,
    shellfact: {
      // go version go1.13.8 linux/amd64 -> "1.13.8 "
      exec: "go version | cut -c14-20",
      fact: "golang_local_version",
    },
    // it might not be installed
    failed_when: false,
  },
  {
    name: "Is the installed version of golang sufficent?",
    debug: {
      msg: tmpl`${golang_local_version} is sufficient.`,
    },
    when: truthy(V.golang_local_version_ok),
  },
  // Otherwise, attempt to install by using apt.
  {
    name: "Installing golang from apt",
    import_tasks: "apt_install.yml",
    when: not(V.golang_local_version_ok),
  },
  // Finally, fall back to downloading and installing.
  {
    name: "Installing golang from source",
    import_tasks: "download_install.yml",
    when: [
      not(V.golang_local_version_ok),
      not(V.golang_apt_version_ok),
    ],
  },
] satisfies TaskFile;
