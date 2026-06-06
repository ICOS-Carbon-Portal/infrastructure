import {
  _dbin_name,
  _dbin_src,
  _dbin_unar,
  _dbin_url,
  dbin_bin_dir,
  dbin_download_dest,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { dbin_repo, dbin_user } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

const dbin_download = register("dbin_download");

export default [
  {
    name: tmpl`Retrieving latest tag for ${dbin_repo}`,
    run_once: true,
    delegate_to: "localhost",
    check_mode: false,
    github_release: {
      user: dbin_user,
      repo: dbin_repo,
      action: "latest_release",
    },
    register: "_release",
  },
  {
    name: "Create download directory",
    file: {
      path: dbin_download_dest,
      state: "directory",
    },
  },
  {
    name: tmpl`Download ${dbin_repo}`,
    get_url: {
      url: _dbin_url,
      dest: dbin_download_dest,
    },
    // This variable can be checked by our users to determine whether anything has
    // changed.
    register: dbin_download,
  },
  {
    name: tmpl`Unarchive ${_dbin_name} tarball`,
    when: truthy(_dbin_unar),
    unarchive: {
      src: dbin_download.dest.ref,
      dest: dbin_download_dest,
      remote_src: true,
      list_files: true,
    },
    diff: false,
    register: "_unar",
  },
  {
    name: tmpl`Create symlink for ${_dbin_name}`,
    file: {
      dest: tmpl`${dbin_bin_dir}/${_dbin_name}`,
      src: _dbin_src,
      state: "link",
    },
    register: "dbin_symlink",
  },
  {
    name: tmpl`Make sure ${_dbin_name} is executable`,
    file: {
      path: _dbin_src,
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
