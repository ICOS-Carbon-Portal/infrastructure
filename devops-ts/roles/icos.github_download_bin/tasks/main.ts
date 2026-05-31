import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl`Retrieving latest tag for ${expr("dbin_repo")}`,
    run_once: true,
    delegate_to: "localhost",
    check_mode: false,
    github_release: {
      user: expr("dbin_user"),
      repo: expr("dbin_repo"),
      action: "latest_release",
    },
    register: "_release",
  },
  {
    name: "Create download directory",
    file: {
      path: V.dbin_download_dest,
      state: "directory",
    },
  },
  {
    name: tmpl`Download ${expr("dbin_repo")}`,
    get_url: {
      url: V._dbin_url,
      dest: V.dbin_download_dest,
    },
    // This variable can be checked by our users to determine whether anything has
    // changed.
    register: "dbin_download",
  },
  {
    name: tmpl`Unarchive ${V._dbin_name} tarball`,
    when: raw("_dbin_unar"),
    unarchive: {
      src: expr("dbin_download.dest"),
      dest: V.dbin_download_dest,
      remote_src: true,
      list_files: true,
    },
    diff: false,
    register: "_unar",
  },
  {
    name: tmpl`Create symlink for ${V._dbin_name}`,
    file: {
      dest: tmpl`${V.dbin_bin_dir}/${V._dbin_name}`,
      src: V._dbin_src,
      state: "link",
    },
    register: "dbin_symlink",
  },
  {
    name: tmpl`Make sure ${V._dbin_name} is executable`,
    file: {
      path: V._dbin_src,
      mode: "+x",
    },
  },
  {
    name: "State what we downloaded",
    debug: {
      msg: `Downloaded version {{ dbin__vers }} of {{ dbin_repo }}
`,
    },
  },
] satisfies TaskFile;
