import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create build directories",
    file: {
      path: tmpl`${V.mailman_home}/build/mailman-${V.item}`,
      state: "directory",
    },
    loop: ["core", "web"],
  },
  {
    name: "Copy mailman files",
    template: {
      dest: "{{ item.dest | default(mailman_home) }}",
      src: "{{ item.src }}",
      mode: "{{ item.mode | default(omit) }}",
    },
    loop: [
      { src: "logrotate.conf" },
      { src: "bbclient-down-hook", mode: "+x" },
      { src: "docker-compose.yml", mode: "0600" },
      { dest: V.mailman_volume_core, src: "mailman-extra.cfg" },
      { dest: V.mailman_volume_web, src: "settings_local.py" },
      { dest: V.mailman_volume_web, src: "Dockerfile.web" },
      {
        dest: tmpl`${V.mailman_home}/build/mailman-core/Dockerfile`,
        src: "Dockerfile.core",
      },
    ],
    register: "_files",
  },
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": {
      project_src: V.mailman_home,
      build: "always",
    },
  },
  {
    name: "Test the REST API",
    uri: {
      url: "https://{{ mailman_domains | first }}/rest/3.0/domains",
      user: V.mailman_rest_user,
      password: "{{ mailman_rest_pass }}",
    },
    register: "r",
    failed_when: [
      "r.status != 200",
      "r.json | json_query('entries[*].mail_host') | sort != mailman_domains | sort",
    ],
    retries: 10,
    delay: 20,
    until: "not r.failed",
  },
  {
    name: "Set postfix parameters",
    postconf: {
      param: "{{ item.param }}",
      value: "{{ item.value }}",
      append: "{{ item.append | default(omit) }}",
    },
    loop: V.mailman_postfix_config,
  },
  {
    name: "delete_spam tasks",
    tags: "mailman_delete_spam",
    block: [
      {
        name: "Copy mailman_delete_spam files",
        template: {
          dest: "{{ item.dest | default(mailman_home) }}",
          src: "{{ item.src }}",
          mode: "{{ item.mode | default(omit) }}",
        },
        loop: [
          { src: "delete_spam_hyperkitty.py" },
          { src: "get_spam_ids.py" },
          { src: "requirements.txt" },
        ],
        register: "_files",
      },
      {
        name: "Write config.ini file",
        copy: {
          dest: tmpl`${V.mailman_home}/config.ini`,
          mode: 0o644,
          content: `[mm_settings]
url    = https://{{ mailman_domains | first }}/rest/3.0/
user   = {{ mailman_rest_user }}
pass   = {{ vault_mailman_rest_pass }}
hyperkittyuser = {{ vault_mailman_hyperkitty_user }}
hyperkittypass = {{ vault_mailman_hyperkitty_pass }}
`,
        },
      },
      {
        name: "Install required modules into Python virtual environment",
        "ansible.builtin.pip": {
          virtualenv: tmpl`${V.mailman_home}/mailman-web-venv`,
          virtualenv_command: "python3 -m venv",
          requirements: tmpl`${V.mailman_home}/requirements.txt`,
        },
      },
      {
        name: "Install mailman-delete-spam timer",
        include_role: { name: "icos.timer" },
        vars: {
          timer_user: V.mailman_user,
          timer_home: V.mailman_home,
          timer_name: "mailman-delete-spam",
          timer_conf: `OnCalendar=*-*-* 4:05:00
`,
          timer_content: `#!/bin/bash
{{ mailman_home }}/mailman-web-venv/bin/python3 {{ mailman_home }}/get_spam_ids.py
docker exec mailman-web mkdir -p /opt/mailman-web/scripts
docker cp {{ mailman_home }}/all_spam_ids.csv mailman-web:/opt/mailman-web-data/
docker cp {{ mailman_home }}/delete_spam_hyperkitty.py mailman-web:/opt/mailman-web/scripts
docker exec mailman-web /opt/mailman-web/manage.py runscript delete_spam_hyperkitty
`,
        },
      },
    ],
  },
  { import_tasks: "just.yml", tags: "mailman_just" },
] satisfies TaskFile;
