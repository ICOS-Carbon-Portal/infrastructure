-- Auto-generated from ../../../../devops/roles/icos.mailman/tasks/main.yml

[
    {
      name = Some "Create build directories",
      file = Some { path = "{{ mailman_home }}/build/mailman-{{ item }}", state = "directory" },
      loop = Some ((< Records : List ({ src : Text, mode : Optional Text, dest : Optional Text }) | Str : Text | Texts : List Text >).Texts [ "core", "web" ]),
      template = None ({ dest : Text, src : Text, mode : Text }),
      register = None Text,
      `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Text }),
      uri = None ({ url : Text, user : Text, password : Text }),
      failed_when = None (List Text),
      retries = None Natural,
      delay = None Natural,
      until = None Text,
      postconf = None ({ param : Text, value : Text, append : Text }),
      tags = None Text,
      block = None (List ({ name : Text, template : Optional ({ dest : Text, src : Text, mode : Text }), loop : Optional (List ({ src : Text })), register : Optional Text, copy : Optional ({ dest : Text, mode : Natural, content : Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text }) })),
      import_tasks = None Text
    }
  , {
      name = Some "Copy mailman files",
      file = None ({ path : Text, state : Text }),
      loop = Some ((< Records : List ({ src : Text, mode : Optional Text, dest : Optional Text }) | Str : Text | Texts : List Text >).Records [
        { src = "logrotate.conf", mode = None Text, dest = None Text }
      , { src = "bbclient-down-hook", mode = Some "+x", dest = None Text }
      , { src = "docker-compose.yml", mode = Some "0600", dest = None Text }
      , { src = "mailman-extra.cfg", mode = None Text, dest = Some "{{ mailman_volume_core }}" }
      , { src = "settings_local.py", mode = None Text, dest = Some "{{ mailman_volume_web }}" }
      , { src = "Dockerfile.web", mode = None Text, dest = Some "{{ mailman_volume_web }}" }
      , {
          src = "Dockerfile.core",
          mode = None Text,
          dest = Some "{{ mailman_home }}/build/mailman-core/Dockerfile"
      }
    ]),
      template = Some {
        dest = "{{ item.dest | default(mailman_home) }}"
      , src = "{{ item.src }}"
      , mode = "{{ item.mode | default(omit) }}"
    },
      register = Some "_files",
      `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Text }),
      uri = None ({ url : Text, user : Text, password : Text }),
      failed_when = None (List Text),
      retries = None Natural,
      delay = None Natural,
      until = None Text,
      postconf = None ({ param : Text, value : Text, append : Text }),
      tags = None Text,
      block = None (List ({ name : Text, template : Optional ({ dest : Text, src : Text, mode : Text }), loop : Optional (List ({ src : Text })), register : Optional Text, copy : Optional ({ dest : Text, mode : Natural, content : Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text }) })),
      import_tasks = None Text
    }
  , {
      name = Some "Start containers",
      file = None ({ path : Text, state : Text }),
      loop = None (< Records : List ({ src : Text, mode : Optional Text, dest : Optional Text }) | Str : Text | Texts : List Text >),
      template = None ({ dest : Text, src : Text, mode : Text }),
      register = None Text,
      `community.docker.docker_compose_v2` = Some { project_src = "{{ mailman_home }}", build = "always" },
      uri = None ({ url : Text, user : Text, password : Text }),
      failed_when = None (List Text),
      retries = None Natural,
      delay = None Natural,
      until = None Text,
      postconf = None ({ param : Text, value : Text, append : Text }),
      tags = None Text,
      block = None (List ({ name : Text, template : Optional ({ dest : Text, src : Text, mode : Text }), loop : Optional (List ({ src : Text })), register : Optional Text, copy : Optional ({ dest : Text, mode : Natural, content : Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text }) })),
      import_tasks = None Text
    }
  , {
      name = Some "Test the REST API",
      file = None ({ path : Text, state : Text }),
      loop = None (< Records : List ({ src : Text, mode : Optional Text, dest : Optional Text }) | Str : Text | Texts : List Text >),
      template = None ({ dest : Text, src : Text, mode : Text }),
      register = Some "r",
      `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Text }),
      uri = Some {
        url = "https://{{ mailman_domains | first }}/rest/3.0/domains"
      , user = "{{ mailman_rest_user }}"
      , password = "{{ mailman_rest_pass }}"
    },
      failed_when = Some [
        "r.status != 200"
      , "r.json | json_query('entries[*].mail_host') | sort != mailman_domains | sort"
    ],
      retries = Some 10,
      delay = Some 20,
      until = Some "not r.failed",
      postconf = None ({ param : Text, value : Text, append : Text }),
      tags = None Text,
      block = None (List ({ name : Text, template : Optional ({ dest : Text, src : Text, mode : Text }), loop : Optional (List ({ src : Text })), register : Optional Text, copy : Optional ({ dest : Text, mode : Natural, content : Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text }) })),
      import_tasks = None Text
    }
  , {
      name = Some "Set postfix parameters",
      file = None ({ path : Text, state : Text }),
      loop = Some ((< Records : List ({ src : Text, mode : Optional Text, dest : Optional Text }) | Str : Text | Texts : List Text >).Str "{{ mailman_postfix_config }}"),
      template = None ({ dest : Text, src : Text, mode : Text }),
      register = None Text,
      `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Text }),
      uri = None ({ url : Text, user : Text, password : Text }),
      failed_when = None (List Text),
      retries = None Natural,
      delay = None Natural,
      until = None Text,
      postconf = Some {
        param = "{{ item.param }}"
      , value = "{{ item.value }}"
      , append = "{{ item.append | default(omit) }}"
    },
      tags = None Text,
      block = None (List ({ name : Text, template : Optional ({ dest : Text, src : Text, mode : Text }), loop : Optional (List ({ src : Text })), register : Optional Text, copy : Optional ({ dest : Text, mode : Natural, content : Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text }) })),
      import_tasks = None Text
    }
  , {
      name = Some "delete_spam tasks",
      file = None ({ path : Text, state : Text }),
      loop = None (< Records : List ({ src : Text, mode : Optional Text, dest : Optional Text }) | Str : Text | Texts : List Text >),
      template = None ({ dest : Text, src : Text, mode : Text }),
      register = None Text,
      `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Text }),
      uri = None ({ url : Text, user : Text, password : Text }),
      failed_when = None (List Text),
      retries = None Natural,
      delay = None Natural,
      until = None Text,
      postconf = None ({ param : Text, value : Text, append : Text }),
      tags = Some "mailman_delete_spam",
      block = Some [
        {
          name = "Copy mailman_delete_spam files",
          template = Some {
            dest = "{{ item.dest | default(mailman_home) }}"
          , src = "{{ item.src }}"
          , mode = "{{ item.mode | default(omit) }}"
        },
          loop = Some [
            { src = "delete_spam_hyperkitty.py" }
          , { src = "get_spam_ids.py" }
          , { src = "requirements.txt" }
        ],
          register = Some "_files",
          copy = None ({ dest : Text, mode : Natural, content : Text }),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
        }
      , {
          name = "Write config.ini file",
          template = None ({ dest : Text, src : Text, mode : Text }),
          loop = None (List ({ src : Text })),
          register = None Text,
          copy = Some {
            dest = "{{ mailman_home }}/config.ini"
          , mode = 420
          , content = ''
            [mm_settings]
            url    = https://{{ mailman_domains | first }}/rest/3.0/
            user   = {{ mailman_rest_user }}
            pass   = {{ vault_mailman_rest_pass }}
            hyperkittyuser = {{ vault_mailman_hyperkitty_user }}
            hyperkittypass = {{ vault_mailman_hyperkitty_pass }}

          ''
        },
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
        }
      , {
          name = "Install required modules into Python virtual environment",
          template = None ({ dest : Text, src : Text, mode : Text }),
          loop = None (List ({ src : Text })),
          register = None Text,
          copy = None ({ dest : Text, mode : Natural, content : Text }),
          `ansible.builtin.pip` = Some {
            virtualenv = "{{ mailman_home }}/mailman-web-venv"
          , virtualenv_command = "python3 -m venv"
          , requirements = "{{ mailman_home }}/requirements.txt"
        },
          include_role = None ({ name : Text }),
          vars = None ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
        }
      , {
          name = "Install mailman-delete-spam timer",
          template = None ({ dest : Text, src : Text, mode : Text }),
          loop = None (List ({ src : Text })),
          register = None Text,
          copy = None ({ dest : Text, mode : Natural, content : Text }),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          include_role = Some { name = "icos.timer" },
          vars = Some {
            timer_user = "{{ mailman_user }}"
          , timer_home = "{{ mailman_home }}"
          , timer_name = "mailman-delete-spam"
          , timer_conf = ''
            OnCalendar=*-*-* 4:05:00

          ''
          , timer_content = ''
            #!/bin/bash
            {{ mailman_home }}/mailman-web-venv/bin/python3 {{ mailman_home }}/get_spam_ids.py
            docker exec mailman-web mkdir -p /opt/mailman-web/scripts
            docker cp {{ mailman_home }}/all_spam_ids.csv mailman-web:/opt/mailman-web-data/
            docker cp {{ mailman_home }}/delete_spam_hyperkitty.py mailman-web:/opt/mailman-web/scripts
            docker exec mailman-web /opt/mailman-web/manage.py runscript delete_spam_hyperkitty

          ''
        }
        }
    ],
      import_tasks = None Text
    }
  , {
      name = None Text,
      file = None ({ path : Text, state : Text }),
      loop = None (< Records : List ({ src : Text, mode : Optional Text, dest : Optional Text }) | Str : Text | Texts : List Text >),
      template = None ({ dest : Text, src : Text, mode : Text }),
      register = None Text,
      `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Text }),
      uri = None ({ url : Text, user : Text, password : Text }),
      failed_when = None (List Text),
      retries = None Natural,
      delay = None Natural,
      until = None Text,
      postconf = None ({ param : Text, value : Text, append : Text }),
      tags = Some "mailman_just",
      block = None (List ({ name : Text, template : Optional ({ dest : Text, src : Text, mode : Text }), loop : Optional (List ({ src : Text })), register : Optional Text, copy : Optional ({ dest : Text, mode : Natural, content : Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text }) })),
      import_tasks = Some "just.yml"
    }
]
