-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , file : Optional ({ path : Text, mode : Optional Natural, state : Text, owner : Text, group : Text })
    , template : Optional ({ dest : Text, src : Text, lstrip_blocks : Bool })
    , notify : Optional Text
    , loop : Optional (List Text)
    , become : Optional Bool
    , become_user : Optional Text
    , command : Optional Text
    , args : Optional ({ chdir : Text, creates : Text })
    , `ansible.builtin.shell` : Optional Text
    , register : Optional Text
    , changed_when : Optional Bool
    , when : Optional Text
    , debug : Optional ({ msg : Text })
    , postconf : Optional ({ param : Text, value : Text, append : Text })
    , user : Optional ({ name : Text, append : Bool, groups : List Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , file = None ({ path : Text, mode : Optional Natural, state : Text, owner : Text, group : Text })
    , template = None ({ dest : Text, src : Text, lstrip_blocks : Bool })
    , notify = None Text
    , loop = None (List Text)
    , become = None Bool
    , become_user = None Text
    , command = None Text
    , args = None ({ chdir : Text, creates : Text })
    , `ansible.builtin.shell` = None Text
    , register = None Text
    , changed_when = None Bool
    , when = None Text
    , debug = None ({ msg : Text })
    , postconf = None ({ param : Text, value : Text, append : Text })
    , user = None ({ name : Text, append : Bool, groups : List Text })
  }
    }

in  [
    Task::{ name = "Install opendkim", apt = Some { name = [ "opendkim", "opendkim-tools" ] } }
  , Task::{
      name = "Create keys directory",
      file = Some {
        path = "{{ opendkim_keys }}"
      , mode = Some 448
      , state = "directory"
      , owner = "{{ opendkim_user }}"
      , group = "{{ opendkim_user }}"
    }
    }
  , Task::{
      name = "Create opendkim.conf",
      template = Some { dest = "/etc/opendkim.conf", src = "opendkim.conf", lstrip_blocks = True },
      notify = Some "Restart opendkim"
    }
  , Task::{
      name = "Create config files",
      template = Some { dest = "/etc/opendkim", src = "{{ item }}", lstrip_blocks = True },
      notify = Some "Restart opendkim",
      loop = Some [ "signing.table", "key.table", "trusted.hosts" ]
    }
  , Task::{
      name = "Create key directory for domain",
      file = Some {
        path = "{{ opendkim_keys }}/{{ item }}"
      , mode = None Natural
      , state = "directory"
      , owner = "{{ opendkim_user }}"
      , group = "{{ opendkim_user }}"
    },
      loop = Some [ "{{ opendkim_domains }}" ]
    }
  , Task::{
      name = "Create domain keys",
      loop = Some [ "{{ opendkim_domains }}" ],
      become = Some True,
      become_user = Some "{{ opendkim_user }}",
      command = Some "opendkim-genkey -b 2048 -d {{ item }} -s default -v && chmod 600 default.private",
      args = Some { chdir = "{{ opendkim_keys }}/{{ item }}", creates = "default.private" }
    }
  , Task::{
      name = "Find domain keys that needs to be added to DNS",
      `ansible.builtin.shell` = Some ''
      for d in {{ opendkim_domains | difference(opendkim_domains_testkeys) | join(" ") }}; do
        echo -n "default._domainkey $d ";
        cat {{ opendkim_keys }}/$d/default.txt | sed -n 'N;N;s/.*( //g;s/\x0A/ /g;s/).*//g;s/"[[:blank:]]*"//g;s/"//g;p';
      done
    '',
      register = Some "_r",
      changed_when = Some False,
      when = Some "opendkim_domains | difference(opendkim_domains_testkeys)"
    }
  , Task::{
      name = "Print instructions about adding DNS records",
      when = Some "opendkim_domains | difference(opendkim_domains_testkeys)",
      debug = Some {
        msg = ''
        Create the following DNS records:
        "{{ _r.stdout }}"

      ''
    }
    }
  , Task::{
      name = "Run opendkim-testkey on keys that have been added to DNS",
      loop = Some [ "{{ opendkim_domains_testkeys }}" ],
      command = Some "opendkim-testkey -d {{ item }} -s default -vvv",
      changed_when = Some False
    }
  , Task::{
      name = "Create socket directory",
      file = Some {
        path = "{{ opendkim_sock | dirname }}"
      , mode = None Natural
      , state = "directory"
      , owner = "opendkim"
      , group = "postfix"
    }
    }
  , Task::{
      name = "Configure postfix",
      notify = Some "Restart postfix",
      loop = Some [
        { param = "smtpd_milters", value = "local:opendkim/opendkim.sock", append = Some True }
      , { param = "non_smtpd_milters", value = "$smtpd_milters", append = None Bool }
    ],
      postconf = Some {
        param = "{{ item.param }}"
      , value = "{{ item.value }}"
      , append = "{{ item.append | default(omit) }}"
    }
    }
  , Task::{
      name = "Add postfix to the opendkim group",
      notify = Some "Restart postfix",
      user = Some { name = "postfix", append = True, groups = [ "opendkim" ] }
    }
]
