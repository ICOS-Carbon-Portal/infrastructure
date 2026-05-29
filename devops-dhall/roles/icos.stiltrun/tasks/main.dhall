-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "List docker images matching the stiltrun image",
      command = Some "docker images -qa {{stiltrun_image_name}}",
      register = Some "docker_images",
      changed_when = Some "False"
    }
  , Task::{
      when = Some [ "stiltrun_image_id not in docker_images.stdout" ],
      become = Some "{{ stiltrun_user != \"root\" }}",
      become_user = Some "{{ stiltrun_user }}",
      block = Some (let Task =
        { Type =
            { name : Optional Text
        , check_mode : Optional Bool
        , shellfact : Optional ({ exec : Text, fact : Text })
        , authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text })
        , blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural })
        , command : Optional Text
        , register : Optional Text
        , changed_when : Optional Text
        , failed_when : Optional (List Text)
        , github_release : Optional ({ user : Text, repo : Text, action : Text })
        , set_fact : Optional ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text })
        , args : Optional ({ chdir : Text })
        , notify : Optional Text
        , import_tasks : Optional Text
        , uri : Optional ({ url : Text, user : Optional Text, password : Optional Text })
        , systemd : Optional ({ name : Text, state : Optional Text })
        , copy : Optional ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural })
        , file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , loop : Optional (List Text)
        , docker_image : Optional ({ source : Text, name : Text, build : { path : Text } })
        , apt : Optional ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural })
        , when : Optional Text
        , shell : Optional Text
        , known_hosts : Optional ({ path : Text, name : Text, key : Text })
        , import_role : Optional ({ name : Text, tasks_from : Text })
        , template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text })
        , `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text })
        , include_role : Optional ({ name : Text })
        , vars : Optional ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) })
        , slurp : Optional ({ src : Text })
        , delegate_to : Optional Text
        , expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } })
        , iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text })
        , iptables_raw : Optional ({ name : Text, rules : Text })
        , debug : Optional ({ msg : Text })
        , tags : Optional Text
        , `community.postgresql.postgresql_set` : Optional ({ name : Text, value : Text })
        , user : Optional ({ name : Text, home : Optional Text, state : Optional Text })
        , run_once : Optional Bool
        , fetch : Optional ({ src : Text, dest : Text, flat : Bool })
        , get_url : Optional ({ url : Text, dest : Text })
        , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text })
        , fail : Optional ({ msg : Text })
        , `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text })
        , `ansible.builtin.shell` : Optional Text
        , retries : Optional Natural
      }
        , default =
            { name = None Text
        , check_mode = None Bool
        , shellfact = None ({ exec : Text, fact : Text })
        , authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text })
        , blockinfile = None ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural })
        , command = None Text
        , register = None Text
        , changed_when = None Text
        , failed_when = None (List Text)
        , github_release = None ({ user : Text, repo : Text, action : Text })
        , set_fact = None ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text })
        , args = None ({ chdir : Text })
        , notify = None Text
        , import_tasks = None Text
        , uri = None ({ url : Text, user : Optional Text, password : Optional Text })
        , systemd = None ({ name : Text, state : Optional Text })
        , copy = None ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural })
        , file = None ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , loop = None (List Text)
        , docker_image = None ({ source : Text, name : Text, build : { path : Text } })
        , apt = None ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural })
        , when = None Text
        , shell = None Text
        , known_hosts = None ({ path : Text, name : Text, key : Text })
        , import_role = None ({ name : Text, tasks_from : Text })
        , template = None ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text })
        , `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text })
        , include_role = None ({ name : Text })
        , vars = None ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) })
        , slurp = None ({ src : Text })
        , delegate_to = None Text
        , expect = None ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } })
        , iptables = None ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text })
        , iptables_raw = None ({ name : Text, rules : Text })
        , debug = None ({ msg : Text })
        , tags = None Text
        , `community.postgresql.postgresql_set` = None ({ name : Text, value : Text })
        , user = None ({ name : Text, home : Optional Text, state : Optional Text })
        , run_once = None Bool
        , fetch = None ({ src : Text, dest : Text, flat : Bool })
        , get_url = None ({ url : Text, dest : Text })
        , `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text })
        , fail = None ({ msg : Text })
        , `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text })
        , `ansible.builtin.shell` = None Text
        , retries = None Natural
      }
        }

    in  [
        Task::{
          name = Some "Download stilt docker image",
          register = Some "_get_url",
          get_url = Some { url = "{{ stiltrun_image_url }}", dest = "/tmp" }
        }
      , Task::{
          name = Some "Load stilt image into docker",
          command = Some "docker load -i \"{{ _get_url.dest }}\"",
          changed_when = Some "False"
        }
      , Task::{
          name = Some "Check that stiltrun_image was properly loaded",
          changed_when = Some "False",
          shell = Some "docker images -q | grep {{ stiltrun_image_id }} -q"
        }
      , Task::{
          name = Some "Tag the stiltrun image",
          changed_when = Some "False",
          shell = Some "docker tag {{stiltrun_image_id}} {{stiltrun_image_name}}"
        }
    ])
    }
  , Task::{
      name = Some "Install the stilt python wrapper",
      template = Some {
        src = "stilt.py"
      , dest = "/usr/local/bin/stilt"
      , mode = Some "493"
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      register = Some "_stilt_py"
    }
  , Task::{
      name = Some "Test stiltrun by running listmetfiles",
      command = Some "{{ _stilt_py.dest }} listmetfiles",
      changed_when = Some "False"
    }
  , Task::{
      name = Some "Test stiltrun by running calcslots",
      command = Some "{{ _stilt_py.dest }} calcslots 2012010100 2012010106",
      register = Some "stilt_output",
      changed_when = Some "False",
      failed_when = Some "False"
    }
  , Task::{
      name = Some "Check the output of calcslots",
      `assert` = Some {
        that = [ "stilt_output.stdout == \"2012010100\\n2012010103\\n2012010106\"" ]
      , quiet = None Bool
    },
      changed_when = Some "False"
    }
]
