import { raw, type TaskFile } from "../../../lib/ansible.ts";

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
      msg: "{{ golang_local_version }} is sufficient.",
    },
    when: raw("golang_local_version_ok"),
  },
  // Otherwise, attempt to install by using apt.
  {
    name: "Installing golang from apt",
    import_tasks: "apt_install.yml",
    when: raw("not golang_local_version_ok"),
  },
  // Finally, fall back to downloading and installing.
  {
    name: "Installing golang from source",
    import_tasks: "download_install.yml",
    when: [
      raw("not golang_local_version_ok"),
      raw("not golang_apt_version_ok"),
    ],
  },
] satisfies TaskFile;
