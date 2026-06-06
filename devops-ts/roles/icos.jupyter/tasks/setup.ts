import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create jupyter home",
    file: {
      path: V.jupyter_home,
      state: "directory",
    },
  },
  {
    name: "Create auth token",
    // https://jupyter.readthedocs.io/en/stable/reference/separate-proxy.html#proxy-configuration
    shell:
      "openssl rand -hex 20 | awk '{ print \"CONFIGPROXY_AUTH_TOKEN=\" $1 }' > auth_token.env",
    args: {
      chdir: V.jupyter_home,
      creates: "auth_token.env",
    },
  },
  // We want the network to be external to docker-compose, so that it leaves it
  // alone when it goes down, since the notebook containers need it.
  {
    name: "Create jupyter network",
    docker_network: { name: "jupyter" },
  },
  {
    name: "Copy files",
    copy: {
      dest: V.jupyter_home,
      src: V.item,
    },
    loop: ["build.hub", "docker-compose.yml"],
  },
  {
    name: "Copy jupyterhub_config.py",
    template: {
      src: "jupyterhub_config.py",
      dest: tmpl`${V.jupyter_home}/jupyterhub_home/`,
    },
    vars: {
      conf: V.jupyter_hub_config_defaults.combine(V.jupyter_hub_config),
    },
    register: "_config",
  },
  {
    name: "Start proxy and hub",
    "community.docker.docker_compose_v2": {
      project_src: V.jupyter_home,
    },
  },
  {
    name: "Restart the hub",
    "community.docker.docker_compose_v2": {
      project_src: V.jupyter_home,
      services: ["hub"],
      state: "restarted",
      build: "always",
    },
    changed_when: false,
  },
] satisfies TaskFile;
