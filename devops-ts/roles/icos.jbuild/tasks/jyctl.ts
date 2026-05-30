import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_role: "name=icos.python3" },
  {
    name: "Create jyctl user",
    user: {
      name: "jyctl",
      home: "/opt/jyctl",
      groups: "docker",
      append: true,
    },
    register: "_user",
  },
  {
    name: "Change access rights on template directory",
    file: {
      path: "{{ item }}",
      owner: "{{ _user.uid }}",
      group: "{{ _user.group }}",
    },
    loop: ["/docker/jupyter/jupyterhub_home/templates"],
  },
  {
    name: "Change access rights on /opt/jyctl",
    file: {
      path: "/opt/jyctl",
      mode: "0700",
    },
  },
  {
    name: "Login to registry",
    become: true,
    become_user: "jyctl",
    "community.general.docker_login": {
      registry_url: "{{ jbuild_registry.url }}",
      username: "{{ jbuild_registry.username }}",
      password: "{{ jbuild_registry.password }}",
    },
  },
  {
    name: "Remove virtual env",
    file: {
      path: "/opt/jyctl/venv",
      state: "absent",
    },
    when: raw("virtualenv_recreate | default(False) | bool"),
  },
  {
    name: "Create virtual env",
    pip: {
      virtualenv: "/opt/jyctl/venv",
      name: ["click", "docker"],
      state: "present",
    },
  },
  {
    name: "Copy jyctl.py",
    copy: {
      src: "jyctl.py",
      dest: "/opt/jyctl/jyctl.py",
      mode: "+x",
      force: "{{ jbuild_force | default(True) | bool }}",
    },
  },
  {
    name: "Add keys to authorized_keys",
    authorized_key: {
      user: "jyctl",
      key_options: 'command="/opt/jyctl/jyctl.py"',
      key: `{% for elt in _jbuild_user_keys.results -%}
{{ elt.public_key }}
{% endfor %}
`,
    },
  },
  {
    name: "Allow jyctl to login",
    copy: {
      dest: "/etc/ssh/sshd_config.d/jyctl_allow_users.conf",
      content: `AllowUsers jyctl
`,
    },
    notify: "reload sshd",
  },
] satisfies TaskFile;
