import {
  isNotDefined,
  raw,
  register,
  type TaskFile,
  type When,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const gh = register("gh");

const _version = register("_version");

export default [
  // 20231210 - ripgrep currently doesn't provide prebuilt binaries for e.g ARM.
  {
    // Original `when:` is a YAML list (implicitly AND-ed by Ansible); preserve
    // the list structure rather than collapsing to a single `a and b` string.
    when: [
      raw('ansible_architecture == "x86_64"'),
      isNotDefined(V.ripgrep_version),
    ] as unknown as When,
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of ripgrep",
        github_release: {
          user: "BurntSushi",
          repo: "ripgrep",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set ripgrep_version fact",
        set_fact: {
          ripgrep_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    when: raw('ansible_architecture == "x86_64"'),
    name: "Install ripgrep using .deb from github",
    apt: { deb: V.ripgrep_url_map.at(V.ansible_architecture) },
  },
  // Hope that some version of ripgrep is bundled with OS.
  {
    when: raw('ansible_architecture != "x86_64"'),
    block: [
      {
        name: "Install ripgrep using apt",
        apt: { name: ["ripgrep"] },
      },
    ],
  },
  {
    name: "Check that ripgrep is executable",
    shell: "rg --version | head -1",
    changed_when: false,
    register: _version,
  },
  {
    name: "Which version of ripgrep was installed",
    debug: { msg: tmpl`Installed ${_version.stdout.ref}` },
  },
] satisfies TaskFile;
