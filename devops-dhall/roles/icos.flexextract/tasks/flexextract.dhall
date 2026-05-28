-- Auto-generated from flexextract.yml

let Item =
    { Type =
        { name : Optional Text
    , tags : Optional Text
    , synchronize : Optional ({ src : Text, dest : Text })
    , shell : Optional Text
    , args : Optional ({ chdir : Text, executable : Text })
    , register : Optional Text
    , changed_when : Optional Text
    , when : Optional Text
    , become : Optional Bool
    , become_user : Optional Text
    , file : Optional ({ path : Optional Text, state : Text, owner : Optional Text, group : Optional Text, dest : Optional Text, src : Optional Text })
    , import_tasks : Optional Text
  }
    , default =
        { name = None Text
    , tags = None Text
    , synchronize = None ({ src : Text, dest : Text })
    , shell = None Text
    , args = None ({ chdir : Text, executable : Text })
    , register = None Text
    , changed_when = None Text
    , when = None Text
    , become = None Bool
    , become_user = None Text
    , file = None ({ path : Optional Text, state : Text, owner : Optional Text, group : Optional Text, dest : Optional Text, src : Optional Text })
    , import_tasks = None Text
  }
    }

in  [
    Item::{
      name = Some "Copy {{ flexextract_src_dir }} directory",
      tags = Some "flexextract_sync",
      synchronize = Some { src = "{{ flexextract_src_dir }}/", dest = "{{ flexextract_home }}/build" }
    }
  , Item::{
      name = Some "Build flexextract image",
      tags = Some "flexextract_build",
      shell = Some ''
      set -o pipefail
      ( echo -n '=== starting build '; date; \
        docker build -t {{ flexextract_tag }} build --pull) \
      | tee -a build.log

    '',
      args = Some { chdir = "{{ flexextract_home }}", executable = "/bin/bash" },
      register = Some "_output",
      changed_when = Some "\" ---> Running in \" in _output.stdout",
      when = Some "flexextract_docker_build | default(True)"
    }
  , Item::{
      name = Some "Create download directory",
      become = Some True,
      become_user = Some "root",
      file = Some {
        path = Some "{{ flexextract_download_host }}"
      , state = "directory"
      , owner = Some "{{ flexextract_user }}"
      , group = Some "{{ flexextract_user }}"
      , dest = None Text
      , src = None Text
    }
    }
  , Item::{
      name = Some "Create a link to the download directory in home directory",
      when = Some "flexextract_download_host  != (flexextract_home+\"/download\")",
      file = Some {
        path = None Text
      , state = "link"
      , owner = None Text
      , group = None Text
      , dest = Some "{{ flexextract_home }}/download"
      , src = Some "{{ flexextract_download_host }}"
    }
    }
  , Item::{ tags = Some "flexextract_script", import_tasks = Some "script.yml" }
]
