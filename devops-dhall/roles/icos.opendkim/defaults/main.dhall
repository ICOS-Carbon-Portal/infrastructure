-- Auto-generated from ../../../../devops/roles/icos.opendkim/defaults/main.yml

{
    opendkim_user = "opendkim"
  , opendkim_keys = "/etc/opendkim/keys"
  , opendkim_domains_testkeys = [] : List Text
  , opendkim_sock = "/var/spool/postfix/opendkim/opendkim.sock"
}
