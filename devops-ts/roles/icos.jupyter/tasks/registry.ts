import { localVar, type TaskFile, V } from "../../../lib/ansible.ts";

export default [
  {
    name: "Login to registry",
    tags: "login",
    become: true,
    become_user: "root",
    "community.general.docker_login": {
      registry_url: "registry.icos-cp.eu",
      username: "docker",
      password: V.vault_registry_pass,
    },
  },
  {
    name: "Pull the notebook image from registry",
    docker_image: {
      name: localVar<{ image: string }>("conf").image,
      source: "pull",
    },
    vars: {
      conf: V.jupyter_hub_config_defaults.combine(V.jupyter_hub_config),
    },
  },
] satisfies TaskFile;
