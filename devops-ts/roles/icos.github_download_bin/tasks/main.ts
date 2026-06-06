import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { truthy } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

const dbin_download = register("dbin_download");

export default [
  {
    name: tmpl`Retrieving latest tag for ${V.dbin_repo}`,
    run_once: true,
    delegate_to: "localhost",
    check_mode: false,
    github_release: {
      user: V.dbin_user,
      repo: V.dbin_repo,
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
    name: tmpl`Download ${V.dbin_repo}`,
    get_url: {
      url: V._dbin_url,
      dest: V.dbin_download_dest,
    },
    // This variable can be checked by our users to determine whether anything has
    // changed.
    register: dbin_download,
  },
  {
    name: tmpl`Unarchive ${V._dbin_name} tarball`,
    when: truthy(V._dbin_unar),
    unarchive: {
      src: dbin_download.dest.ref,
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
