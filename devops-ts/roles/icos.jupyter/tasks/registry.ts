import { jupyter_hub_config, jupyter_hub_config_defaults } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { localVar } from "../../../lib/template.ts";
import { vault_registry_pass } from "../../../lib/vaultvars.ts";

export default [
  {
    name: "Login to registry",
    tags: "login",
    become: true,
    become_user: "root",
    "community.general.docker_login": {
      registry_url: "registry.icos-cp.eu",
      username: "docker",
      password: vault_registry_pass,
    },
  },
  {
    name: "Pull the notebook image from registry",
    docker_image: {
      name: localVar<{ image: string }>("conf").image,
      source: "pull",
    },
    vars: {
      conf: jupyter_hub_config_defaults.combine(jupyter_hub_config),
    },
  },
] satisfies TaskFile;
