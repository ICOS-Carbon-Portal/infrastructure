import { fd_architecture, fd_url_map, fd_version } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { eq, isNotDefined, ne, not } from "../../../lib/vars.ts";

const gh = register("gh");
const _r = register("_r");

export default [
  {
    when: isNotDefined(fd_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of fd",
        github_release: {
          user: "sharkdp",
          repo: "fd",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set fd_version fact",
        set_fact: {
          fd_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  // Installing using the .deb is preferable because then we get manual pages etc
  // as well. But currently .deb only exist for x86_64.
  {
    when: eq(fd_architecture, "x86_64"),
    name: "Install fd",
    apt: { deb: fd_url_map.at(fd_architecture) },
  },
  // For other architecture we'll just extract the fd binary.
  {
    when: ne(fd_architecture, "x86_64"),
    name: "Unarchive fd",
    unarchive: {
      remote_src: true,
      src: fd_url_map.at(fd_architecture),
      dest: "/usr/local/bin",
      include: ["fd-*/fd"],
      extra_opts: ["--strip-components=1", "--wildcards"],
    },
  },
  {
    name: "Check that fd is executable and the correct version",
    shell: "fd --version",
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(fd_version)),
  },
  {
    name: "Which version of fd was installed",
    run_once: true,
    debug: { msg: tmpl`Installed ${fd_version}\n` },
  },
] satisfies TaskFile;
