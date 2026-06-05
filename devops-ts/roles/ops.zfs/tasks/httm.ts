import {
  isNotDefined,
  ne,
  not,
  register,
  type TaskFile,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const gh = register("gh");
const _r = register("_r");

export default [
  {
    name: "Architecture is not supported",
    fail: {
      msg: tmpl`httm is not supported on ${V.ansible_architecture}`,
    },
    when: ne(V.ansible_architecture, "x86_64"),
  },
  {
    when: isNotDefined(V.httm_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of httm",
        github_release: {
          user: "kimono-koans",
          repo: "httm",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set httm_version fact",
        set_fact: {
          httm_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install httm",
    apt: {
      deb: V.httm_url_map.at(V.httm_architecture),
    },
  },
  {
    name: "Check that httm is executable and the correct version",
    shell: "httm --version",
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(V.httm_version)),
  },
  {
    name: "Which version of httm was installed",
    debug: {
      msg: tmpl`Installed ${V.httm_version}`,
    },
  },
] satisfies TaskFile;
