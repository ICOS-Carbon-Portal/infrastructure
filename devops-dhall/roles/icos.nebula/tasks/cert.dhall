-- Auto-generated from cert.yml

let Item =
    { Type =
        { name : Optional Text
    , command : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , debug : Optional ({ msg : Text })
    , when : Optional Text
    , block : Optional (List ({ name : Text, slurp : Optional ({ src : Text }), register : Optional Text, delegate_to : Optional Text, expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }), copy : Optional ({ dest : Text, content : Text }), command : Optional Text, changed_when : Optional Text, notify : Optional Text }))
  }
    , default =
        { name = None Text
    , command = None Text
    , changed_when = None Bool
    , register = None Text
    , debug = None ({ msg : Text })
    , when = None Text
    , block = None (List ({ name : Text, slurp : Optional ({ src : Text }), register : Optional Text, delegate_to : Optional Text, expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }), copy : Optional ({ dest : Text, content : Text }), command : Optional Text, changed_when : Optional Text, notify : Optional Text }))
  }
    }

in  [
    Item::{
      name = Some "Check status of certificate",
      command = Some "ops-nebula cert-check {{ nebula_cert_min_days }}",
      changed_when = Some False,
      register = Some "status"
    }
  , Item::{
      name = Some "Cert status",
      debug = Some {
        msg = ''
        {{status.stdout_lines[0]}}

      ''
    },
      when = Some "status.stdout_lines"
    }
  , Item::{
      when = Some "status.stdout and status.stdout_lines[-1] == \"need to sign\"",
      block = Some [
        {
          name = "Retrieve public key",
          slurp = Some { src = "/etc/nebula/new.pub" },
          register = Some "newpub",
          delegate_to = None Text,
          expect = None ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }),
          copy = None ({ dest : Text, content : Text }),
          command = None Text,
          changed_when = None Text,
          notify = None Text
        }
      , {
          name = "Sign pubkey to create certificate",
          slurp = None ({ src : Text }),
          register = Some "signedcert",
          delegate_to = Some "localhost",
          expect = Some {
            chdir = "{{ nebula_cert_sign | fileglob | first | dirname }}"
          , command = "/bin/bash -c 'nebula-cert sign -ca-crt {{nebula_cert_sign | basename}} -ca-key {{nebula_cert_sign | basename | splitext | first}}.key -in-pub <(echo \"{{ newpub.content | b64decode }}\") -ip {{ nebula_ip }}{{ nebula_netmask }} -name {{ nebula_hostname }} -out-crt crt.sign && cat crt.sign && rm crt.sign'"
          , responses = { `Enter passphrase: ` = "{{ nebula_passphrase | default ('') }}" }
        },
          copy = None ({ dest : Text, content : Text }),
          command = None Text,
          changed_when = None Text,
          notify = None Text
        }
      , {
          name = "Write signed certificate",
          slurp = None ({ src : Text }),
          register = None Text,
          delegate_to = None Text,
          expect = None ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }),
          copy = Some { dest = "/etc/nebula/new.crt", content = "{{ signedcert.stdout }}" },
          command = None Text,
          changed_when = None Text,
          notify = None Text
        }
      , {
          name = "Pick up new status",
          slurp = None ({ src : Text }),
          register = Some "status",
          delegate_to = None Text,
          expect = None ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }),
          copy = None ({ dest : Text, content : Text }),
          command = Some "ops-nebula cert-check {{ nebula_cert_min_days }}",
          changed_when = Some "status.stdout_lines[-1] == \"need to restart\"",
          notify = Some "restart nebula"
        }
    ]
    }
]
