-- Auto-generated from ../../../../devops/roles/icos.vmagent/tasks/really_install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Find the latest release of VictoriaMetrics",
      run_once = Some True,
      delegate_to = Some "localhost",
      check_mode = Some False,
      github_release = Some { user = "VictoriaMetrics", repo = "VictoriaMetrics", action = "latest_release" },
      register = Some "release"
    }
  , Task::{
      name = Some "Download vmagent release",
      get_url = Some {
        url = "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/{{ release.tag }}/vmutils-linux-{{ vmagent_arch }}-{{ release.tag }}.tar.gz",
        dest = "/tmp",
        force = None Text,
        mode = None Text
    },
      register = Some "url"
    }
  , Task::{
      name = Some "Unarchive vmagent",
      unarchive = Some {
        src = "{{ url.dest }}",
        dest = "{{ vmagent_bin }}",
        remote_src = True,
        owner = None Text,
        group = None Text,
        include = None ((List Text)),
        list_files = None Bool,
        extra_opts = None ((List Text)),
        mode = None Text,
        creates = None Text
    },
      diff = Some False,
      register = Some "unar",
      notify = Some [ "restart vmagent" ]
    }
]
