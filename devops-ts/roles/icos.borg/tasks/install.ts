import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { isIn, isNotDefined, not } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

const gh = register("gh");
const _r = register("_r");

export default [
  {
    when: isNotDefined(V.borg_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of borg",
        github_release: {
          user: "borgbackup",
          repo: "borg",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set borg_version fact",
        set_fact: {
          borg_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Architecture is not supported",
    fail: {
      msg: tmpl`borg is not supported on ${V.ansible_architecture}`,
    },
    when: isIn(V.ansible_architecture, ["armv6l", "armv7l", "aarch64"]),
  },
  {
    name: "Download borg",
    get_url: {
      url: V.borg_url_map.at(V.ansible_architecture),
      dest: V.borg_bin,
      force: V.borg_upgrade,
      mode: "+x",
    },
  },
  {
    name: "Check that borg is executable and the correct version",
    shell: tmpl`${V.borg_bin} --version`,
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(V.borg_version)),
  },
  {
    name: "Which version of borg is installed",
    debug: {
      msg: tmpl`Installed ${V.borg_version}`,
    },
  },
] satisfies TaskFile;
