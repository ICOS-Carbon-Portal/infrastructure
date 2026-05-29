-- Auto-generated from ../../../../devops/roles/icos.rspamd/tasks/config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install milter configuration for rspamd",
      copy = Some {
        dest = "/etc/rspamd/local.d/worker-proxy.inc",
        mode = Some "420",
        content = Some ''
        # This will make the milter listen to all interfaces. Since we're in an
        # LXD container, this will only enable connections from the LXD host.
        bind_socket = "*:11332";
        milter = yes;
        timeout = 120s;
        upstream "local" {
            default = yes;
            self_scan = yes;
        }

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
  , Task::{
      name = Some "Install web ui configuration for rspamd",
      copy = Some {
        dest = "/etc/rspamd/local.d/worker-controller.inc",
        mode = Some "420",
        content = Some ''
        # This will make the Web UI listen to all interfaces. Since we're in an
        # LXD container, this will only enable connections from the LXD host.
        bind_socket = "*:11334";
        password = "{{ rspamd_admin_password_hashed }}"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
  , Task::{
      name = Some "Install autolearning configuration for rspamd",
      copy = Some {
        dest = "/etc/rspamd/local.d/classifier-bayes.conf",
        mode = Some "420",
        content = Some ''
        # This will turn on the autolearn feature.
        autolearn {
          spam_threshold = 6.0; # When to learn spam (score >= threshold and action is reject)
          junk_threshold = 4.0; # When to learn spam (score >= threshold and action is rewrite subject or add header, and has two or more positive results)
          ham_threshold = -0.5; # When to learn ham (score <= threshold and action is no action, and score is negative or has three or more negative results)
          check_balance = true; # Check spam and ham balance
          min_balance = 0.9; # Keep diff for spam/ham learns for at least this value
        }

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
  , Task::{
      name = Some "Adjust symbol weight for neural network",
      copy = Some {
        dest = "/etc/rspamd/local.d/neural_group.conf",
        mode = Some "420",
        content = Some ''
        # Set NEURAL_SPAM to +3, NEURAL_HAM to -0.01

        symbols = {
          "NEURAL_SPAM" {
            weight = 3.0;
            description = "Neural network spam";
          }
          "NEURAL_HAM" {
            weight = -0.01;
            description = "Neural network ham";
          }
        }

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
  , Task::{
      name = Some "Adjust action thresholds",
      copy = Some {
        dest = "/etc/rspamd/local.d/actions.conf",
        mode = Some "420",
        content = Some ''
        reject = 12;
        add_header = 6;
        greylist = 4;

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
  , Task::{
      name = Some "Remove NiXSpam (remove once rspamd is updated to remove this from core)",
      `ansible.builtin.copy` = Some { dest = "{{ item.dest }}", mode = "0644", content = "{{ item.content }}" },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = Some "/etc/rspamd/local.d/rbl.conf",
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = Some ''
            rbls {
              nixspam {
                enabled = false;
              }
            }

          '',
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = Some "/etc/rspamd/local.d/rbl_group.conf",
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = Some ''
            symbols {
              RBL_NIXSPAM {
                enabled = false;
              }
            }

          '',
            port = None Text,
            path = None Text
        }
      ]),
      notify = Some [ "restart rspamd" ]
    }
]
