-- Auto-generated from flexextract.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy {{ flexextract_src_dir }} directory",
      tags = Some [ "flexextract_sync" ],
      synchronize = Some { src = "{{ flexextract_src_dir }}/", dest = "{{ flexextract_home }}/build" }
    }
  , Task::{
      name = Some "Build flexextract image",
      tags = Some [ "flexextract_build" ],
      shell = Some ''
      set -o pipefail
      ( echo -n '=== starting build '; date; \
        docker build -t {{ flexextract_tag }} build --pull) \
      | tee -a build.log

    '',
      args = Some {
        creates = None Text
      , chdir = Some "{{ flexextract_home }}"
      , executable = Some "/bin/bash"
      , removes = None Text
    },
      register = Some "_output",
      changed_when = Some "\" ---> Running in \" in _output.stdout",
      when = Some [ "flexextract_docker_build | default(True)" ]
    }
  , Task::{
      name = Some "Create download directory",
      become = Some "True",
      become_user = Some "root",
      file = Some {
        path = Some "{{ flexextract_download_host }}"
      , state = Some "directory"
      , mode = None Text
      , owner = Some "{{ flexextract_user }}"
      , group = Some "{{ flexextract_user }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Create a link to the download directory in home directory",
      file = Some {
        path = None Text
      , state = Some "link"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "{{ flexextract_home }}/download"
      , recurse = None Bool
      , src = Some "{{ flexextract_download_host }}"
    },
      when = Some [ "flexextract_download_host  != (flexextract_home+\"/download\")" ]
    }
  , Task::{ import_tasks = Some "script.yml", tags = Some [ "flexextract_script" ] }
]
