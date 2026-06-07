import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { jbuild_force, virtualenv_recreate } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { jbuild_registry } from "../_ctx.ts";
import { truthy } from "../../../lib/vars.ts";

const _user = register("_user");

export default [
  {
    name: "Create edctl user",
    user: {
      name: "edctl",
      home: "/opt/edctl",
      groups: "docker",
      append: true,
    },
    register: _user,
  },
  {
    name: "Change access rights on /opt/edctl",
    file: {
      path: "/opt/edctl",
      mode: "0700",
    },
  },
  {
    name: "Change access rights on template directories",
    file: {
      path: item,
      owner: _user.uid.ref,
      group: _user.group.ref,
    },
    loop: [
      "/docker/exploredata.test/jupyterhub_home/templates",
      "/docker/exploredata.prod/jupyterhub_home/templates",
    ],
  },
  {
    name: "Login to registry",
    become: true,
    become_user: "edctl",
    "community.general.docker_login": {
      registry_url: jbuild_registry.url,
      username: jbuild_registry.username,
      password: jbuild_registry.password,
    },
  },
  {
    name: "Remove virtual env",
    file: {
      path: "/opt/edctl/venv",
      state: "absent",
    },
    when: truthy(virtualenv_recreate).default(false).bool(),
  },
  {
    name: "Create virtual env",
    pip: {
      virtualenv: "/opt/edctl/venv",
      name: ["click", "docker"],
    },
  },
  {
    name: "Copy edctl.py",
    copy: {
      src: "edctl.py",
      dest: "/opt/edctl/edctl.py",
      mode: "+x",
      force: jbuild_force.default(true).bool(),
    },
  },
  {
    name: "Add keys to authorized_keys",
    authorized_key: {
      user: "edctl",
      key_options: 'command="/opt/edctl/edctl.py"',
      key: `{% for elt in _jbuild_user_keys.results -%}
{{ elt.public_key }}
{% endfor %}
`,
    },
  },
] satisfies TaskFile;
