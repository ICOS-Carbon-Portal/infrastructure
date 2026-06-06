// Names-only registry of vault-defined variables (ansible-vault files are
// encrypted, so these cannot be auto-generated; the names are hand-curated
// from references in converted playbooks — each came from working YAML that
// verify.ts proved identical). Names only: the V accessor maps every key to
// a Ref, so the uniform `string` type is never consulted.
// Add a name here when a converted playbook first references it.
export interface VaultVars {
  vault_amalthea_ssh_keys: string;
  vault_aquanet_form_git_repo: string;
  vault_callisto_admins: string;
  vault_callisto_sftp_fluxcom_upload_password: string;
  vault_callisto_sftp_fluxcom_upload_username: string;
  vault_callisto_sftp_password: string;
  vault_callisto_user_conf: string;
  vault_callisto_user_volumes: string;
  vault_cdb_root_keys: string;
  vault_city_restheart_basic_auth: string;
  vault_cpauth_mailing_pass: string;
  vault_cpauth_mailing_smtp: string;
  vault_cpauth_masteradmin_pass: string;
  vault_cpauth_oauth_conf: string;
  vault_cpauth_user_secret_salt: string;
  vault_cpdata_dlreporter_pass: string;
  vault_cpdata_etcfacade_secret: string;
  vault_cpdata_irods_pass: string;
  vault_cpdata_sentry_backend_dsn: string;
  vault_cpdata_sentry_portal_dsn: string;
  vault_cpmeta_sentry_dsn: string;
  vault_ctehires_user_conf: string;
  vault_cupcake_user_conf: string;
  vault_doi_admins: string;
  vault_doi_password: string;
  vault_doi_test_password: string;
  vault_doi_to_addresses: string;
  vault_dokku_root_keys: string;
  vault_erddap_root_keys: string;
  vault_eurocom_users: string;
  vault_exploredata_password: string;
  vault_exploredata_root_keys: string;
  vault_flexextract_user_conf: string;
  vault_flexpart_admins: string;
  vault_fsicos2_root_keys: string;
  vault_fsicos4_vms_root_keys: string;
  vault_ganymede_jbuild_users: string;
  vault_ganymede_jupyter_admins: string;
  vault_ganymede_sshlogins: string;
  vault_ganymede_user_conf: string;
  vault_geoip_nginx_allow_deny: string;
  vault_jupyter_admins: string;
  vault_jupyter_root_keys: string;
  vault_mailman_admin_email: string;
  vault_mailman_hyperkitty_api_key: string;
  vault_mailman_postgres_password: string;
  vault_mailman_rest_allow_deny: string;
  vault_mailman_rest_pass: string;
  vault_mailman_web_secret_key: string;
  vault_maps_lantmateriet_auth: string;
  vault_matomo_mysql_database_password: string;
  vault_matomo_mysql_database_user: string;
  vault_matomo_mysql_password: string;
  vault_matomo_mysql_root_password: string;
  vault_matomo_mysql_user: string;
  vault_nc_paul_upload_password: string;
  vault_nextcloud_admin_password: string;
  vault_nextcloud_exporter_pass: string;
  vault_nginx_allow_internal_only: string;
  vault_nginx_testing_users: string;
  vault_onlyoffice_secret: string;
  vault_pancake_user_conf: string;
  vault_plausible_google_client_id: string;
  vault_plausible_google_client_secret: string;
  vault_plausible_mailer_email: string;
  vault_plausible_postgres_password: string;
  vault_plausible_secret: string;
  vault_plausible_totp_key: string;
  vault_postgis_admin_pass: string;
  vault_postgis_reader_pass: string;
  vault_postgis_user_conf: string;
  vault_postgis_writer_pass: string;
  vault_prometheus_promlens_token: string;
  vault_pw_salt: string;
  vault_quince3_user_conf: string;
  vault_rdflog_db_pass: string;
  vault_rdflog_rep_pass: string;
  vault_registry_pass: string;
  vault_registry_users: string;
  vault_root_keys: string;
  vault_rspamd_admin_password: string;
  vault_rspamd_admin_password_hashed: string;
  vault_stiltweb_atmoaccess_user_password: string;
  vault_virtuoso_dba_pass: string;
  vault_vmagent_auth: { username: string; password: string };
  vault_vm_graf_pass: string;
}

// === auto-generated variable bindings (gen-bindings.ts); do not edit below ===
import { varProxy, type VarRef } from "./template.ts";
const vref = <K extends keyof VaultVars>(k: K): VarRef<VaultVars[K]> =>
  varProxy(k) as VarRef<VaultVars[K]>;

export const vault_amalthea_ssh_keys = vref("vault_amalthea_ssh_keys");
export const vault_aquanet_form_git_repo = vref("vault_aquanet_form_git_repo");
export const vault_callisto_admins = vref("vault_callisto_admins");
export const vault_callisto_sftp_fluxcom_upload_password = vref(
  "vault_callisto_sftp_fluxcom_upload_password",
);
export const vault_callisto_sftp_fluxcom_upload_username = vref(
  "vault_callisto_sftp_fluxcom_upload_username",
);
export const vault_callisto_sftp_password = vref(
  "vault_callisto_sftp_password",
);
export const vault_callisto_user_conf = vref("vault_callisto_user_conf");
export const vault_callisto_user_volumes = vref("vault_callisto_user_volumes");
export const vault_cdb_root_keys = vref("vault_cdb_root_keys");
export const vault_city_restheart_basic_auth = vref(
  "vault_city_restheart_basic_auth",
);
export const vault_cpauth_mailing_pass = vref("vault_cpauth_mailing_pass");
export const vault_cpauth_mailing_smtp = vref("vault_cpauth_mailing_smtp");
export const vault_cpauth_masteradmin_pass = vref(
  "vault_cpauth_masteradmin_pass",
);
export const vault_cpauth_oauth_conf = vref("vault_cpauth_oauth_conf");
export const vault_cpauth_user_secret_salt = vref(
  "vault_cpauth_user_secret_salt",
);
export const vault_cpdata_dlreporter_pass = vref(
  "vault_cpdata_dlreporter_pass",
);
export const vault_cpdata_etcfacade_secret = vref(
  "vault_cpdata_etcfacade_secret",
);
export const vault_cpdata_irods_pass = vref("vault_cpdata_irods_pass");
export const vault_cpdata_sentry_backend_dsn = vref(
  "vault_cpdata_sentry_backend_dsn",
);
export const vault_cpdata_sentry_portal_dsn = vref(
  "vault_cpdata_sentry_portal_dsn",
);
export const vault_cpmeta_sentry_dsn = vref("vault_cpmeta_sentry_dsn");
export const vault_ctehires_user_conf = vref("vault_ctehires_user_conf");
export const vault_cupcake_user_conf = vref("vault_cupcake_user_conf");
export const vault_doi_admins = vref("vault_doi_admins");
export const vault_doi_password = vref("vault_doi_password");
export const vault_doi_test_password = vref("vault_doi_test_password");
export const vault_doi_to_addresses = vref("vault_doi_to_addresses");
export const vault_dokku_root_keys = vref("vault_dokku_root_keys");
export const vault_erddap_root_keys = vref("vault_erddap_root_keys");
export const vault_eurocom_users = vref("vault_eurocom_users");
export const vault_exploredata_password = vref("vault_exploredata_password");
export const vault_exploredata_root_keys = vref("vault_exploredata_root_keys");
export const vault_flexextract_user_conf = vref("vault_flexextract_user_conf");
export const vault_flexpart_admins = vref("vault_flexpart_admins");
export const vault_fsicos2_root_keys = vref("vault_fsicos2_root_keys");
export const vault_fsicos4_vms_root_keys = vref("vault_fsicos4_vms_root_keys");
export const vault_ganymede_jbuild_users = vref("vault_ganymede_jbuild_users");
export const vault_ganymede_jupyter_admins = vref(
  "vault_ganymede_jupyter_admins",
);
export const vault_ganymede_sshlogins = vref("vault_ganymede_sshlogins");
export const vault_ganymede_user_conf = vref("vault_ganymede_user_conf");
export const vault_geoip_nginx_allow_deny = vref(
  "vault_geoip_nginx_allow_deny",
);
export const vault_jupyter_admins = vref("vault_jupyter_admins");
export const vault_jupyter_root_keys = vref("vault_jupyter_root_keys");
export const vault_mailman_admin_email = vref("vault_mailman_admin_email");
export const vault_mailman_hyperkitty_api_key = vref(
  "vault_mailman_hyperkitty_api_key",
);
export const vault_mailman_postgres_password = vref(
  "vault_mailman_postgres_password",
);
export const vault_mailman_rest_allow_deny = vref(
  "vault_mailman_rest_allow_deny",
);
export const vault_mailman_rest_pass = vref("vault_mailman_rest_pass");
export const vault_mailman_web_secret_key = vref(
  "vault_mailman_web_secret_key",
);
export const vault_maps_lantmateriet_auth = vref(
  "vault_maps_lantmateriet_auth",
);
export const vault_matomo_mysql_database_password = vref(
  "vault_matomo_mysql_database_password",
);
export const vault_matomo_mysql_database_user = vref(
  "vault_matomo_mysql_database_user",
);
export const vault_matomo_mysql_password = vref("vault_matomo_mysql_password");
export const vault_matomo_mysql_root_password = vref(
  "vault_matomo_mysql_root_password",
);
export const vault_matomo_mysql_user = vref("vault_matomo_mysql_user");
export const vault_nc_paul_upload_password = vref(
  "vault_nc_paul_upload_password",
);
export const vault_nextcloud_admin_password = vref(
  "vault_nextcloud_admin_password",
);
export const vault_nextcloud_exporter_pass = vref(
  "vault_nextcloud_exporter_pass",
);
export const vault_nginx_allow_internal_only = vref(
  "vault_nginx_allow_internal_only",
);
export const vault_nginx_testing_users = vref("vault_nginx_testing_users");
export const vault_onlyoffice_secret = vref("vault_onlyoffice_secret");
export const vault_pancake_user_conf = vref("vault_pancake_user_conf");
export const vault_plausible_google_client_id = vref(
  "vault_plausible_google_client_id",
);
export const vault_plausible_google_client_secret = vref(
  "vault_plausible_google_client_secret",
);
export const vault_plausible_mailer_email = vref(
  "vault_plausible_mailer_email",
);
export const vault_plausible_postgres_password = vref(
  "vault_plausible_postgres_password",
);
export const vault_plausible_secret = vref("vault_plausible_secret");
export const vault_plausible_totp_key = vref("vault_plausible_totp_key");
export const vault_postgis_admin_pass = vref("vault_postgis_admin_pass");
export const vault_postgis_reader_pass = vref("vault_postgis_reader_pass");
export const vault_postgis_user_conf = vref("vault_postgis_user_conf");
export const vault_postgis_writer_pass = vref("vault_postgis_writer_pass");
export const vault_prometheus_promlens_token = vref(
  "vault_prometheus_promlens_token",
);
export const vault_pw_salt = vref("vault_pw_salt");
export const vault_quince3_user_conf = vref("vault_quince3_user_conf");
export const vault_rdflog_db_pass = vref("vault_rdflog_db_pass");
export const vault_rdflog_rep_pass = vref("vault_rdflog_rep_pass");
export const vault_registry_pass = vref("vault_registry_pass");
export const vault_registry_users = vref("vault_registry_users");
export const vault_root_keys = vref("vault_root_keys");
export const vault_rspamd_admin_password = vref("vault_rspamd_admin_password");
export const vault_rspamd_admin_password_hashed = vref(
  "vault_rspamd_admin_password_hashed",
);
export const vault_stiltweb_atmoaccess_user_password = vref(
  "vault_stiltweb_atmoaccess_user_password",
);
export const vault_virtuoso_dba_pass = vref("vault_virtuoso_dba_pass");
export const vault_vm_graf_pass = vref("vault_vm_graf_pass");
export const vault_vmagent_auth = vref("vault_vmagent_auth");
