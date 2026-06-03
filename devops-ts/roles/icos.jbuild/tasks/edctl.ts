import { raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

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
      path: V.item,
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
      registry_url: V.jbuild_registry.url,
      username: V.jbuild_registry.username,
      password: V.jbuild_registry.password,
    },
  },
  {
    name: "Remove virtual env",
    file: {
      path: "/opt/edctl/venv",
      state: "absent",
    },
    when: raw("virtualenv_recreate | default(False) | bool"),
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
      force: V.jbuild_force.default(true).bool(),
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
