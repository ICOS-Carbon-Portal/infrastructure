-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , run_once : Optional Bool
    , delegate_to : Optional Text
    , check_mode : Optional Bool
    , github_release : Optional ({ user : Text, repo : Text, action : Text })
    , register : Optional Text
    , file : Optional ({ path : Optional Text, state : Optional Text, dest : Optional Text, src : Optional Text, mode : Optional Text })
    , get_url : Optional ({ url : Text, dest : Text })
    , when : Optional Text
    , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool, list_files : Bool })
    , diff : Optional Bool
    , debug : Optional ({ msg : Text })
  }
    , default =
        { run_once = None Bool
    , delegate_to = None Text
    , check_mode = None Bool
    , github_release = None ({ user : Text, repo : Text, action : Text })
    , register = None Text
    , file = None ({ path : Optional Text, state : Optional Text, dest : Optional Text, src : Optional Text, mode : Optional Text })
    , get_url = None ({ url : Text, dest : Text })
    , when = None Text
    , unarchive = None ({ src : Text, dest : Text, remote_src : Bool, list_files : Bool })
    , diff = None Bool
    , debug = None ({ msg : Text })
  }
    }

in  [
    Entry::{
      name = "Retrieving latest tag for {{ dbin_repo }}",
      run_once = Some True,
      delegate_to = Some "localhost",
      check_mode = Some False,
      github_release = Some { user = "{{ dbin_user }}", repo = "{{ dbin_repo }}", action = "latest_release" },
      register = Some "_release"
    }
  , Entry::{
      name = "Create download directory",
      file = Some {
        path = Some "{{ dbin_download_dest }}"
      , state = Some "directory"
      , dest = None Text
      , src = None Text
      , mode = None Text
    }
    }
  , Entry::{
      name = "Download {{ dbin_repo }}",
      register = Some "dbin_download",
      get_url = Some { url = "{{ _dbin_url }}", dest = "{{ dbin_download_dest }}" }
    }
  , Entry::{
      name = "Unarchive {{ _dbin_name }} tarball",
      register = Some "_unar",
      when = Some "_dbin_unar",
      unarchive = Some {
        src = "{{ dbin_download.dest }}"
      , dest = "{{ dbin_download_dest }}"
      , remote_src = True
      , list_files = True
    },
      diff = Some False
    }
  , Entry::{
      name = "Create symlink for {{ _dbin_name }}",
      register = Some "dbin_symlink",
      file = Some {
        path = None Text
      , state = Some "link"
      , dest = Some "{{ dbin_bin_dir }}/{{ _dbin_name }}"
      , src = Some "{{ _dbin_src }}"
      , mode = None Text
    }
    }
  , Entry::{
      name = "Make sure {{ _dbin_name }} is executable",
      file = Some {
        path = Some "{{ _dbin_src }}"
      , state = None Text
      , dest = None Text
      , src = None Text
      , mode = Some "+x"
    }
    }
  , Entry::{
      name = "State what we downloaded",
      debug = Some {
        msg = ''
        Downloaded version {{ dbin__vers }} of {{ dbin_repo }}

      ''
    }
    }
]
