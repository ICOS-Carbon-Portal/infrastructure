import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  // First install standard version of caddy, this will create the caddy user and
  // setup systemd service files.
  { import_tasks: "install.yml" },
  { import_tasks: "just.yml", tags: "caddy_just" },
  // If we're not using any extra modules, then we're mostly done.
  {
    name: "Install plain caddy",
    include_tasks: "plain.yml",
    when: raw("not caddy_modules"),
  },
  // If any modules are needed we need xcaddy instead.
  {
    include_tasks: {
      file: "xcaddy.yml",
      apply: { tags: "caddy_modules" },
    },
    tags: "caddy_xcaddy",
    when: raw("caddy_modules"),
  },
  {
    name: "Check that caddy was properly installed",
    "ansible.builtin.shell": "{{ caddy_bin }} version",
    changed_when: false,
  },
  {
    name: "Set caddy global configuration",
    include_tasks: "global.yml",
  },
  {
    name: "Configure caddy site",
    include_tasks: {
      file: "site.yml",
      apply: { tags: "caddy_site" },
    },
    tags: "caddy_site",
    when: raw("caddy_name is defined"),
  },
] satisfies TaskFile;
