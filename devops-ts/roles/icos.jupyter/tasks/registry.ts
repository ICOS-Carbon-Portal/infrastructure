import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Login to registry",
    tags: "login",
    become: true,
    become_user: "root",
    "community.general.docker_login": {
      registry_url: "registry.icos-cp.eu",
      username: "docker",
      password: tmpl("{{ vault_registry_pass }}"),
    },
  },
  {
    name: "Pull the notebook image from registry",
    docker_image: {
      name: tmpl("{{ conf.image }}"),
      source: "pull",
    },
    vars: {
      conf: tmpl(
        "{{ jupyter_hub_config_defaults | combine(jupyter_hub_config) }}",
      ),
    },
  },
] satisfies TaskFile;
