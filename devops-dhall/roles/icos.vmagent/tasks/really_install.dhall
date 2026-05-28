-- Auto-generated from really_install.yml

let Entry =
    { Type =
        { name : Text
    , run_once : Optional Bool
    , delegate_to : Optional Text
    , check_mode : Optional Bool
    , github_release : Optional ({ user : Text, repo : Text, action : Text })
    , register : Text
    , get_url : Optional ({ url : Text, dest : Text })
    , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool })
    , diff : Optional Bool
    , notify : Optional Text
  }
    , default =
        { run_once = None Bool
    , delegate_to = None Text
    , check_mode = None Bool
    , github_release = None ({ user : Text, repo : Text, action : Text })
    , get_url = None ({ url : Text, dest : Text })
    , unarchive = None ({ src : Text, dest : Text, remote_src : Bool })
    , diff = None Bool
    , notify = None Text
  }
    }

in  [
    Entry::{
      name = "Find the latest release of VictoriaMetrics",
      run_once = Some True,
      delegate_to = Some "localhost",
      check_mode = Some False,
      github_release = Some { user = "VictoriaMetrics", repo = "VictoriaMetrics", action = "latest_release" },
      register = "release"
    }
  , Entry::{
      name = "Download vmagent release",
      register = "url",
      get_url = Some {
        url = "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/{{ release.tag }}/vmutils-linux-{{ vmagent_arch }}-{{ release.tag }}.tar.gz"
      , dest = "/tmp"
    }
    }
  , Entry::{
      name = "Unarchive vmagent",
      register = "unar",
      unarchive = Some { src = "{{ url.dest }}", dest = "{{ vmagent_bin }}", remote_src = True },
      diff = Some False,
      notify = Some "restart vmagent"
    }
]
