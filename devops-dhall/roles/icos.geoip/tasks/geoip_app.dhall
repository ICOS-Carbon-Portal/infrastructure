-- Auto-generated from geoip_app.yml

let Task =
    { Type =
        { name : Text
    , git : Optional ({ repo : Text, version : Text, dest : Text, force : Bool })
    , register : Optional Text
    , shell : Optional Text
    , args : Optional ({ chdir : Text, executable : Text })
    , changed_when : Optional Text
    , when : Optional Text
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text })
    , uri : Optional ({ url : Text, return_content : Bool })
    , failed_when : Optional Text
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
    , tags : Optional Text
  }
    , default =
        { git = None ({ repo : Text, version : Text, dest : Text, force : Bool })
    , register = None Text
    , shell = None Text
    , args = None ({ chdir : Text, executable : Text })
    , changed_when = None Text
    , when = None Text
    , `community.docker.docker_compose_v2` = None ({ project_src : Text })
    , uri = None ({ url : Text, return_content : Bool })
    , failed_when = None Text
    , retries = None Natural
    , delay = None Natural
    , until = None Text
    , tags = None Text
  }
    }

in  [
    Task::{
      name = "Pull source",
      git = Some {
        repo = "{{ geoip_git_repo }}"
      , version = "{{ geoip_git_version }}"
      , dest = "{{ geoip_repo_dir }}"
      , force = True
    },
      register = Some "_git"
    }
  , Task::{
      name = "Build geoip images using docker-compose",
      register = Some "_output",
      shell = Some ''
      set -o pipefail
      ( echo -n '=== starting build '; date; docker-compose build --pull) \
      | tee -a build.log

    '',
      args = Some { chdir = "{{ geoip_home }}", executable = "/bin/bash" },
      changed_when = Some "\" ---> Running in \" in _output.stdout",
      when = Some "geoip_docker_build | default(True)"
    }
  , Task::{
      name = "Start containers",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ geoip_home }}" }
    }
  , Task::{
      name = "Check that geoip responds",
      register = Some "r",
      uri = Some {
        url = "http://{{ certbot_domains | first }}:/ip/8.8.8.8"
      , return_content = True
    },
      failed_when = Some "r.failed or r.json | json_query('ip') != '8.8.8.8'",
      retries = Some 2,
      delay = Some 10,
      until = Some "not r.failed",
      tags = Some "geoip_check"
    }
]
