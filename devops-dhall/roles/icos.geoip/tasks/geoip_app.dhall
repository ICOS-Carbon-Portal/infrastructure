-- Auto-generated from geoip_app.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Pull source",
      git = Some {
        repo = "{{ geoip_git_repo }}"
      , version = Some "{{ geoip_git_version }}"
      , dest = "{{ geoip_repo_dir }}"
      , force = Some True
      , update = None Text
      , key_file = None Text
    },
      register = Some "_git"
    }
  , Task::{
      name = Some "Build geoip images using docker-compose",
      shell = Some ''
      set -o pipefail
      ( echo -n '=== starting build '; date; docker-compose build --pull) \
      | tee -a build.log

    '',
      args = Some {
        creates = None Text
      , chdir = Some "{{ geoip_home }}"
      , executable = Some "/bin/bash"
      , removes = None Text
    },
      register = Some "_output",
      changed_when = Some "\" ---> Running in \" in _output.stdout",
      when = Some [ "geoip_docker_build | default(True)" ]
    }
  , Task::{
      name = Some "Start containers",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ geoip_home }}"
      , state = None Text
      , pull = None Text
      , services = None (List Text)
      , build = None Text
    }
    }
  , Task::{
      name = Some "Check that geoip responds",
      uri = Some {
        url = "http://{{ certbot_domains | first }}:/ip/8.8.8.8"
      , return_content = Some True
      , method = None Text
      , user = None Text
      , password = None Text
    },
      register = Some "r",
      failed_when = Some "r.failed or r.json | json_query('ip') != '8.8.8.8'",
      retries = Some 2,
      delay = Some 10,
      until = Some "not r.failed",
      tags = Some [ "geoip_check" ]
    }
]
