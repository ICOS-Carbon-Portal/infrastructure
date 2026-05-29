-- Auto-generated from ../../../../devops/roles/icos.vmagent/tasks/proxy.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      when = Some [ "vmagent_proxy == \"probe\"" ],
      name = Some "Probe for vmagent_proxy fact",
      check_mode = Some False,
      shellfact = Some {
        exec = "ss -Htlp 'sport 443' | sed -re 's/.*(nginx|caddy).*/\\1/' | uniq",
        fact = "vmagent_proxy",
        bool = None Bool,
        list = None Bool
    }
    }
  , Task::{
      when = Some [ "vmagent_proxy not in ('nginx', 'caddy')" ],
      check_mode = Some False,
      name = Some "Fail if we can't figure out which proxy server is used",
      fail = Some {
        msg = ''
        Unknown proxy server "{{ vmagent_proxy }}".

      ''
    }
    }
  , Task::{
      when = Some [ "vmagent_proxy == 'nginx'" ],
      name = Some "Setup nginx proxy for vmagent",
      include_role = Some (Task.Poly_include_role.Record {
          apply = None (({ tags : Text })),
          name = "icos.nginxsite",
          tasks_from = None Text,
          public = None Bool
      })
    }
  , Task::{
      when = Some [ "vmagent_proxy == 'caddy'" ],
      name = Some "Setup caddy proxy for vmagent",
      include_role = Some (Task.Poly_include_role.Record {
          apply = None (({ tags : Text })),
          name = "icos.caddy",
          tasks_from = Some "site.yml",
          public = None Bool
      })
    }
  , Task::{ name = Some "Flush handlers", meta = Some "flush_handlers" }
  , Task::{
      when = Some [ "vmagent_auth" ],
      block = Some (let Entry =
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
        Entry::{
          name = Some "Test that the vmagent UI is password protected",
          register = Some "r",
          failed_when = Some [ "r.status != 401" ],
          uri = Some {
            url = "https://{{ inventory_hostname }}/vmagent/"
          , user = None Text
          , password = None Text
        },
          retries = Some 10
        }
      , Entry::{
          name = Some "Test that the vmagent UI works with password",
          register = Some "r",
          uri = Some {
            url = "https://{{ inventory_hostname }}/vmagent/"
          , user = Some "{{ vmagent_auth.username }}"
          , password = Some "{{ vmagent_auth.password }}"
        },
          retries = Some 10
        }
    ])
    }
]
