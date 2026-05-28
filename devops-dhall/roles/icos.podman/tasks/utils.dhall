-- Auto-generated from utils.yml

let Item =
    { Type =
        { name : Optional Text
    , `community.general.pipx` : Optional ({ name : Text, executable : Text })
    , pip : Optional ({ name : List Text })
    , include_role : Optional ({ name : Text, apply : { tags : Text } })
    , vars : Optional ({ dbin_user : Text, dbin_repo : Text, dbin_src : Text, dbin_url : Text })
  }
    , default =
        { name = None Text
    , `community.general.pipx` = None ({ name : Text, executable : Text })
    , pip = None ({ name : List Text })
    , include_role = None ({ name : Text, apply : { tags : Text } })
    , vars = None ({ dbin_user : Text, dbin_repo : Text, dbin_src : Text, dbin_url : Text })
  }
    }

in  [
    Item::{
      name = Some "Install docker-compose",
      `community.general.pipx` = Some { name = "docker-compose", executable = "pipx-global" }
    }
  , Item::{
      name = Some "Install docker support for ansible's python",
      pip = Some { name = [ "docker", "docker-compose" ] }
    }
  , Item::{
      include_role = Some { name = "icos.github_download_bin", apply = { tags = "podman_utils" } },
      vars = Some {
        dbin_user = "jesseduffield"
      , dbin_repo = "lazydocker"
      , dbin_src = "lazydocker"
      , dbin_url = "{{ dbin__down }}/v{{ dbin__vers }}/{{ dbin_repo }}_{{ dbin__vers }}_Linux_{{ lazydocker_arch }}.tar.gz"
    }
    }
]
