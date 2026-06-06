import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Pull source from git",
    git: {
      repo: V.vault_aquanet_form_git_repo,
      dest: tmpl`${V.project_dir}/repo`,
      key_file: tmpl`${V.project_dir}/.ssh/id_rsa`,
    },
  },
  {
    name: "Copy config",
    template: { src: "config.json", dest: tmpl`${V.project_dir}/repo/` },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml.j2",
      dest: tmpl`${V.project_dir}/docker-compose.yml`,
    },
  },
  {
    name: "Run docker-compose",
    docker_compose: {
      project_src: V.project_dir,
      state: "present",
      build: true,
    },
    notify: "reload nginx config",
  },
] satisfies TaskFile;
