import { ncdu_url } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";

const _ncdu = register("_ncdu");
const _version = register("_version");

export default [
  {
    name: "Install ncdu",
    tags: "ncdu",
    unarchive: {
      remote_src: true,
      src: ncdu_url,
      dest: "/usr/local/bin/",
    },
    register: _ncdu,
    diff: false,
  },
  {
    name: "Check that ncdu is executable",
    command: tmpl`${_ncdu.dest.ref}/ncdu --version`,
    changed_when: false,
    register: _version,
  },
  {
    name: "Which version of ncdu was installed",
    debug: { msg: tmpl`Installed ${_version.stdout.ref}` },
  },
] satisfies TaskFile;
