import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Login to registry",
    tags: "login",
    become: true,
    become_user: "root",
    "community.general.docker_login": {
      registry_url: "registry.icos-cp.eu",
      username: "docker",
      password: expr("vault_registry_pass"),
    },
  },
  {
    name: "Pull the notebook image from registry",
    docker_image: {
      name: expr("conf.image"),
      source: "pull",
    },
    vars: {
      conf: expr("jupyter_hub_config_defaults | combine(jupyter_hub_config)"),
    },
  },
] satisfies TaskFile;
