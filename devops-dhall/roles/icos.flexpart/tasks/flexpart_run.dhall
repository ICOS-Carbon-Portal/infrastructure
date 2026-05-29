-- Auto-generated from ../../../../devops/roles/icos.flexpart/tasks/flexpart_run.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create flexpart user",
      user = Some {
        name = "{{ flexpart_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = None Text,
        home = None Text,
        password_lock = None Bool,
        groups = Some [ "docker" ],
        append = Some "True",
        state = Some "present",
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    },
      register = Some "_user"
    }
  , Task::{
      name = Some "Create the flexpart output directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ flexpart_output_directory }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      become = Some (Task.Poly_become.Bool True),
      become_user = Some "{{ flexpart_user }}",
      block = Some (let Task =
        { Type =
            { name : Optional Text
        , file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user : Optional ({ db : Text, name : Text, password : Text })
        , loop : Optional (List Text)
        , postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text })
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
        , file = None ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount = None ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user = None ({ db : Text, name : Text, password : Text })
        , loop = None (List Text)
        , postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` = None ({ name : Text, db : Text, schema : Text })
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
          name = Some "Create flexpart build dir",
          file = Some {
            path = Some "{{ _user.home }}/build"
          , state = "directory"
          , mode = None Text
          , dest = None Text
          , recurse = None Bool
          , owner = None Text
          , modification_time = None Text
          , access_time = None Text
        },
          register = Some "_build"
        }
      , Task::{
          name = Some "Install the flexpart ssh script",
          copy = Some {
            content = None Text
          , dest = "{{ _user.home }}/flexpart_ssh.sh"
          , backup = None Bool
          , src = Some "flexpart_ssh.sh"
          , mode = Some 493
        }
        }
      , Task::{
          name = Some "Authorize our own ssh key",
          authorized_key = Some {
            user = "{{ flexpart_user }}"
          , state = "present"
          , key = "{{ lookup('file', 'roles/icos.flexpart/files/flexpart.pub') }}"
          , key_options = "command=\"{{ _user.home }}/flexpart_ssh.sh\""
        }
        }
      , Task::{
          name = Some "Install Dockerfile and build resources",
          loop = Some [
            "Dockerfile"
          , "flexpart10.2.tar.gz"
          , "flextraset.lpr"
          , "flexpart.diff"
          , "entrypoint.sh"
          , "candidate_sites.txt"
          , "grib_api.tgz"
          , "options.tgz"
        ],
          register = Some "_resources",
          copy = Some {
            content = None Text
          , dest = "{{ _build.path }}"
          , backup = None Bool
          , src = Some "{{ item }}"
          , mode = None Natural
        }
        }
      , Task::{
          name = Some "Build flexpart image",
          docker_image = Some {
            source = "build"
          , name = "{{ flexpart_image }}"
          , build = { path = "{{ _build.path }}" }
        }
        }
    ])
    }
  , Task::{
      name = Some "Install the flexpart shell scripts",
      template = Some {
        src = "{{ item.src }}",
        dest = "{{ item.dest }}",
        mode = Some "493",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "flexpart.sh.j2",
            dest = Some "/usr/local/bin/flexpart",
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "flexpart_run.sh.j2",
            dest = Some "/usr/local/bin/flexpart_run",
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
      ])
    }
  , Task::{
      when = Some [ "flexpart_export_output_to != \"\"" ],
      block = Some (let Task =
        { Type =
            { name : Optional Text
        , file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user : Optional ({ db : Text, name : Text, password : Text })
        , loop : Optional (List Text)
        , postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text })
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
        , file = None ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount = None ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user = None ({ db : Text, name : Text, password : Text })
        , loop = None (List Text)
        , postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` = None ({ name : Text, db : Text, schema : Text })
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
          name = Some "Install ssh server",
          apt = Some {
            name = [ "nfs-kernel-server" ]
          , state = Some "present"
          , update_cache = None Bool
          , cache_valid_time = None Natural
        }
        }
      , Task::{
          name = Some "Export flexpart output data via nfs",
          blockinfile = Some {
            create = True
          , path = "/etc/exports"
          , marker = "# {mark} ansible/flexpart"
          , block = ''
            {{ flexpart_output_directory }} {{ flexpart_export_output_to }}

          ''
          , state = None Text
          , backup = None Bool
          , insertafter = None Text
          , insertbefore = None Text
          , mode = None Natural
        },
          register = Some "_export"
        }
      , Task::{
          name = Some "Re-export filesystems",
          command = Some "/usr/sbin/exportfs -ra",
          when = Some "_export.changed"
        }
    ])
    }
]
