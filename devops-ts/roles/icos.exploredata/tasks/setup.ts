import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check type of deployment",
    assert: {
      that: "exploredata_type in ('prod', 'test')",
      quiet: true,
    },
  },
  {
    name: "Copy files",
    copy: {
      dest: tmpl`${V.exploredata_home}/`,
      src: V.item,
    },
    loop: ["build.hub", "jupyterhub_home", "docker-compose.yml"],
  },
  {
    name: "Copy jupyterhub_config.py",
    template: {
      src: "jupyterhub_config.py",
      dest: tmpl`${V.exploredata_home}/jupyterhub_home/`,
      backup: true,
      validate: "python3 -m py_compile %s",
    },
  },
  {
    name: "Install runtime environment file",
    copy: {
      dest: tmpl`${V.exploredata_home}/.env`,
      content: `NETWORK_NAME={{ exploredata_network }}
HUB_PORT={{ exploredata_port }}
HUB_RESTART=always
HUB_IMAGE={{ exploredata_hub_image }}
HUB_CONTAINER_NAME={{ exploredata_hub_container }}
NOTEBOOK_IMAGE={{ exploredata_notebook_image }}
PASSWORD={{ exploredata_password[exploredata_type] }}
`,
    },
  },
  {
    name: "Login to registry",
    tags: "docker_login",
    "community.general.docker_login": {
      registry_url: V.registry_domain,
      username: "docker",
      password: "{{ vault_registry_pass }}",
    },
  },
  {
    name: "Make sure that the notebook images are present",
    "community.docker.docker_image": {
      name: V.exploredata_notebook_image,
      source: "pull",
    },
  },
  {
    name: "Build and start the hub image",
    docker_compose: {
      project_src: V.exploredata_home,
      build: true,
    },
  },
] satisfies TaskFile;
