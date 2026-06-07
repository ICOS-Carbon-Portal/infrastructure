// Argument shapes for the most-used Ansible task modules.
//
// These are supersets of actual usage across the playbooks and role tasks
// (derived by analysing every `.yml`). Task references them so a misspelled or
// wrong-typed module arg is caught; the long tail of rarer modules falls
// through Task's index signature instead of being enumerated here.
import type { VarValue } from "./ansible/values.ts";
import type { Tmpl } from "./template.ts";

/** A boolean that may be written as a Jinja template (`"{{ x }}"`). */
export type Flag = boolean | Tmpl;
/** A file mode: `"0644"` or `0644`. */
export type Mode = Tmpl | number;
/** A package/name field that may be one name or a list. */
export type Names = Tmpl | Tmpl[];

export type FileArgs = {
  state?: Tmpl;
  path?: Tmpl;
  name?: Tmpl;
  dest?: Tmpl;
  src?: Tmpl;
  owner?: Tmpl | number;
  group?: Tmpl | number;
  mode?: Mode;
  recurse?: boolean;
  modification_time?: Tmpl;
  access_time?: Tmpl;
};
export type CopyArgs = {
  dest: Tmpl;
  src?: Tmpl;
  content?: Tmpl;
  mode?: Mode;
  owner?: Tmpl;
  group?: Tmpl;
  backup?: boolean;
  remote_src?: boolean;
  force?: boolean;
  validate?: Tmpl;
};
export type TemplateArgs = {
  src: Tmpl;
  dest: Tmpl;
  mode?: Mode;
  owner?: Tmpl;
  group?: Tmpl;
  backup?: boolean;
  lstrip_blocks?: boolean;
  validate?: Tmpl;
  variable_start_string?: Tmpl;
  variable_end_string?: Tmpl;
};
export type SystemdArgs = {
  name?: Tmpl;
  state?: Tmpl;
  enabled?: boolean;
  status?: Tmpl;
  daemon_reload?: Flag;
  "daemon-reload"?: Flag;
};
export type ServiceArgs =
  | Tmpl
  | { name?: Tmpl; state?: Tmpl; enabled?: boolean };
export type AptArgs = {
  name?: Names;
  state?: Tmpl;
  update_cache?: boolean;
  deb?: Tmpl;
  cache_valid_time?: Tmpl | number;
  upgrade?: string | boolean;
  purge?: boolean;
  autoclean?: boolean;
  autoremove?: boolean;
  install_recommends?: boolean;
};
export type PackageArgs = Tmpl | { name?: Names; state?: Tmpl };
export type UserArgs = {
  name: Tmpl;
  home?: Tmpl;
  shell?: Tmpl;
  groups?: Names;
  group?: Tmpl;
  append?: boolean;
  create_home?: Flag;
  state?: Tmpl;
  password?: Tmpl;
  system?: boolean;
  generate_ssh_key?: boolean;
  remove?: Tmpl;
  uid?: Tmpl | number;
  non_unique?: boolean;
  password_lock?: boolean;
};
export type UriArgs = {
  url: Tmpl;
  return_content?: boolean;
  method?: Tmpl;
  user?: Tmpl;
  password?: Tmpl;
};
export type DebugArgs = Tmpl | { msg?: Tmpl; var?: Tmpl };
export type FailArgs = { msg: Tmpl };
export type StatArgs = { path: Tmpl };
export type ShellArgs = Tmpl | { cmd?: Tmpl };
export type SetFactArgs = Tmpl | Record<string, VarValue>;
export type GetUrlArgs = {
  url: Tmpl;
  dest: Tmpl;
  mode?: Mode;
  force?: Flag;
};
export type UnarchiveArgs = {
  src: Tmpl;
  dest: Tmpl;
  remote_src?: boolean;
  extra_opts?: Tmpl[];
  include?: Tmpl[];
  owner?: Tmpl;
  group?: Tmpl;
  mode?: Mode;
  creates?: Tmpl;
  list_files?: boolean;
};
export type PipArgs = Tmpl | {
  name?: Names;
  virtualenv?: Tmpl;
  state?: Tmpl;
  virtualenv_command?: Tmpl;
  requirements?: Tmpl;
};
export type BlockinfileArgs = {
  path: Tmpl;
  marker?: Tmpl;
  block?: Tmpl;
  create?: boolean;
  insertafter?: Tmpl;
  insertbefore?: Tmpl;
  state?: Tmpl;
  backup?: boolean;
  mode?: Mode;
};
export type LineinfileArgs = {
  path: Tmpl;
  line?: Tmpl;
  state?: Tmpl;
  regex?: Tmpl;
  regexp?: Tmpl;
  backrefs?: boolean;
  create?: boolean;
  insertafter?: Tmpl;
  insertbefore?: Tmpl;
  owner?: Tmpl;
  group?: Tmpl;
  mode?: Mode;
};
export type CronArgs = {
  name: Tmpl;
  job?: Tmpl;
  user?: Tmpl;
  hour?: Tmpl;
  minute?: Tmpl;
  state?: Tmpl;
  special_time?: Tmpl;
};
export type GitArgs = {
  repo: Tmpl;
  dest: Tmpl;
  version?: Tmpl;
  update?: boolean;
  force?: boolean;
  key_file?: Tmpl;
};
export type AuthorizedKeyArgs = {
  user: Tmpl;
  key: Tmpl;
  state?: Tmpl;
  key_options?: Tmpl;
  exclusive?: boolean;
};
