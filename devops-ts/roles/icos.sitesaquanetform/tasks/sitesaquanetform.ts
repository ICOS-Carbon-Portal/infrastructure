import { project_dir } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";
import { vault_aquanet_form_git_repo } from "../../../lib/vaultvars.ts";

export default [
  {
    name: "Pull source from git",
    git: {
      repo: vault_aquanet_form_git_repo,
      dest: tmpl`${project_dir}/repo`,
      key_file: tmpl`${project_dir}/.ssh/id_rsa`,
    },
  },
  {
    name: "Copy config",
    template: { src: "config.json", dest: tmpl`${project_dir}/repo/` },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml.j2",
      dest: tmpl`${project_dir}/docker-compose.yml`,
    },
  },
  {
    name: "Run docker-compose",
    docker_compose: {
      project_src: project_dir,
      state: "present",
      build: true,
    },
    notify: "reload nginx config",
  },
] satisfies TaskFile;
