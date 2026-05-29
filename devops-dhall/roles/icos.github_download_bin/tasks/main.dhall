-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Retrieving latest tag for {{ dbin_repo }}",
      run_once = Some True,
      delegate_to = Some "localhost",
      check_mode = Some False,
      github_release = Some { user = "{{ dbin_user }}", repo = "{{ dbin_repo }}", action = "latest_release" },
      register = Some "_release"
    }
  , Task::{
      name = Some "Create download directory",
      file = Some {
        path = Some "{{ dbin_download_dest }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Download {{ dbin_repo }}",
      get_url = Some {
        url = "{{ _dbin_url }}"
      , dest = "{{ dbin_download_dest }}"
      , force = None Text
      , mode = None Text
    },
      register = Some "dbin_download"
    }
  , Task::{
      name = Some "Unarchive {{ _dbin_name }} tarball",
      when = Some [ "_dbin_unar" ],
      unarchive = Some {
        src = "{{ dbin_download.dest }}"
      , dest = "{{ dbin_download_dest }}"
      , remote_src = True
      , owner = None Text
      , group = None Text
      , include = None (List Text)
      , list_files = Some True
      , extra_opts = None (List Text)
      , mode = None Text
      , creates = None Text
    },
      diff = Some False,
      register = Some "_unar"
    }
  , Task::{
      name = Some "Create symlink for {{ _dbin_name }}",
      file = Some {
        path = None Text
      , state = Some "link"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "{{ dbin_bin_dir }}/{{ _dbin_name }}"
      , recurse = None Bool
      , src = Some "{{ _dbin_src }}"
    },
      register = Some "dbin_symlink"
    }
  , Task::{
      name = Some "Make sure {{ _dbin_name }} is executable",
      file = Some {
        path = Some "{{ _dbin_src }}"
      , state = None Text
      , mode = Some "+x"
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "State what we downloaded",
      debug = Some {
        msg = ''
        Downloaded version {{ dbin__vers }} of {{ dbin_repo }}

      ''
    }
    }
]
