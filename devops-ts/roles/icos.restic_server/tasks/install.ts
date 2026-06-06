import {
  restic_server_architecture,
  restic_server_exec,
  restic_server_home,
  restic_server_url_map,
  restic_server_version,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { isNotDefined } from "../../../lib/vars.ts";

const gh = register("gh");

export default [
  {
    when: isNotDefined(restic_server_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of restic_server",
        github_release: {
          user: "restic",
          repo: "rest-server",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set restic_server_version fact",
        set_fact: {
          restic_server_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install restic_server",
    unarchive: {
      remote_src: true,
      src: restic_server_url_map.at(restic_server_architecture),
      dest: tmpl`${restic_server_home}/bin/`,
      mode: "+x",
      include: ["*/rest-server"],
      extra_opts: ["--no-same-owner", "--strip-components=1", "--wildcards"],
    },
  },
  {
    name: "Check that restic_server is executable and the correct version",
    shell: tmpl`${restic_server_exec} --version`,
    changed_when: false,
    register: "_r",
    failed_when: "restic_server_version not in _r.stdout",
  },
  {
    name: "Which version of restic_server was installed",
    debug: { msg: tmpl`Installed ${restic_server_version}` },
  },
] satisfies TaskFile;
