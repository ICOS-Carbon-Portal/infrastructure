-- Auto-generated from mail-postfix.yml

[
    {
      hosts = "fsicos2"
    , roles = [
        {
          role = "icos.postfix",
          tags = "postfix",
          postfix_config_list = Some [
            {
              param = "mynetworks"
            , value = "127.0.0.0/8 172.16.0.0/12 172.19.199.2 172.19.199.3"
          }
        ],
          dovecot_domains = None (List Text),
          opendkim_domains = None (List Text),
          opendkim_domains_testkeys = None (List Text)
        }
      , {
          role = "icos.dovecot",
          tags = "dovecot",
          postfix_config_list = None (List ({ param : Text, value : Text })),
          dovecot_domains = Some [ "otc-nrt.icos-cp.eu" ],
          opendkim_domains = None (List Text),
          opendkim_domains_testkeys = None (List Text)
        }
      , {
          role = "icos.opendkim",
          tags = "opendkim",
          postfix_config_list = None (List ({ param : Text, value : Text })),
          dovecot_domains = None (List Text),
          opendkim_domains = Some [ "lists.icos-ri.eu", "lists.john-project.eu" ],
          opendkim_domains_testkeys = Some [ "lists.icos-ri.eu", "lists.john-project.eu" ]
        }
    ]
    , tasks = [
        {
          name = "Configure postfix to accept a larger attachment size"
        , tags = "postconf"
        , postconf = { param = "message_size_limit", value = "20480000", reload = True }
      }
    ]
  }
]
