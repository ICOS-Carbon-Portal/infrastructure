import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

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
      owner: tmpl("{{ _user.uid }}"),
      group: tmpl("{{ _user.group }}"),
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
      registry_url: tmpl("{{ jbuild_registry.url }}"),
      username: tmpl("{{ jbuild_registry.username }}"),
      password: tmpl("{{ jbuild_registry.password }}"),
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
      force: tmpl("{{ jbuild_force | default(True) | bool }}"),
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
