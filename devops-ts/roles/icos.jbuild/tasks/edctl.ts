import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create edctl user",
    user: {
      name: "edctl",
      home: "/opt/edctl",
      groups: "docker",
      append: true,
    },
    register: "_user",
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
      owner: expr("_user.uid"),
      group: expr("_user.group"),
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
      registry_url: expr("jbuild_registry.url"),
      username: expr("jbuild_registry.username"),
      password: expr("jbuild_registry.password"),
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
      force: expr("jbuild_force | default(True) | bool"),
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
