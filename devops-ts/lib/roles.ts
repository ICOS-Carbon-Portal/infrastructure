// Typed parameter schemas for Ansible roles.
//
// This is the heart of the type-safety story: each role declares exactly which
// variables it accepts and their types. `role("icos.keycloak", { ... })` then
// autocompletes the variable names and rejects unknown / mistyped ones.
//
// Adoption is incremental: when you convert a playbook that uses a role not yet
// listed here, add its schema. Roles with no parameters map to `{}` and can be
// referenced as a bare `role("icos.matomo")`.
//
// `Tmpl` documents that a value may be (or contain) a Jinja2 template string
// like "{{ nexus_home }}/bbclient" — still just a string at the type level, but
// self-documenting at call sites.
export type Tmpl = string;

export interface Roles {
  "icos.keycloak": { kc_hostname: string };
  "icos.matomo": {};
  "icos.geoip": {};
  "icos.nexus": {};

  "icos.bbclient2": {
    bbclient_name: string;
    bbclient_user: string;
    bbclient_home: Tmpl;
    bbclient_coldbackup: Tmpl;
  };

  "icos.certbot2": {
    certbot_name: Tmpl;
    certbot_domains: Tmpl;
  };

  "icos.cpauth": {};

  "icos.postfix": {
    postfix_config_list: { param: string; value: string }[];
  };
  "icos.dovecot": { dovecot_domains: string[] };
  "icos.opendkim": {
    opendkim_domains: string[];
    opendkim_domains_testkeys?: string[];
  };

  // core.yml
  "icos.postgis": {};
  "icos.restheart": {};
  "icos.cpmeta": {};
  "icos.cpdata": { cpdata_netcdf_folder?: string };
  "icos.doi": {};
  "icos.virtuoso": {};
  "icos.nginxsite": { nginxsite_name: string; nginxsite_file?: string };
  "icos.dataold": {};

  // single-app playbooks (no role-level variables)
  "icos.maps": {};
  "icos.drupal": {};
  "icos.typesense": {};
  "icos.plausible": {};
  "icos.sitesaquanetform": {};
  "icos.fairdatapoint": {};
  "icos.nebula": {};
  "icos.stiltweb": {};

  // server bootstrap roles
  "icos.server": {};
  "icos.docker": {};
  "icos.docker2": {};
  "icos.nginx": {};
  "icos.nfs4": {};
  "icos.lxd_server": {};
  "icos.podman": {};
  "icos.caddy": { caddy_name?: string; caddy_conf?: string };
  "icos.bbserver": {};
  "ops.zfs": {};

  // VM guest + utility roles
  "icos.pve_guest": {};
  "icos.utils": {};
  "icos.python3": {};
  "icos.stiltrun": {};
  "icos.stiltcluster": {};

  // monitoring / exporters
  "icos.vmagent": {};
  "icos.node_exporter": {};
  "icos.script_exporter": { sexp_exporters: string[] };
}
