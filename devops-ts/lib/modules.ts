// Argument shapes for the most-used Ansible task modules.
//
// These are supersets of actual usage across the playbooks and role tasks
// (derived by analysing every `.yml`). Task references them so a misspelled or
// wrong-typed module arg is caught; the long tail of rarer modules falls
// through Task's index signature instead of being enumerated here.
import type { VarValue } from "./ansible.ts";

/** A boolean that may be written as a Jinja template (`"{{ x }}"`). */
export type Flag = boolean | string;
/** A file mode: `"0644"` or `0644`. */
export type Mode = string | number;
/** A package/name field that may be one name or a list. */
export type Names = string | string[];

export type FileArgs = {
  state?: string;
  path?: string;
  name?: string;
  dest?: string;
  src?: string;
  owner?: string | number;
  group?: string | number;
  mode?: Mode;
  recurse?: Flag;
  modification_time?: string;
  access_time?: string;
};
export type CopyArgs = {
  dest: string;
  src?: string;
  content?: string;
  mode?: Mode;
  owner?: string;
  group?: string;
  backup?: Flag;
  remote_src?: Flag;
  force?: Flag;
  validate?: string;
};
export type TemplateArgs = {
  src: string;
  dest: string;
  mode?: Mode;
  owner?: string;
  group?: string;
  backup?: Flag;
  lstrip_blocks?: Flag;
  validate?: string;
  variable_start_string?: string;
  variable_end_string?: string;
};
export type SystemdArgs = {
  name?: string;
  state?: string;
  enabled?: Flag;
  status?: string;
  daemon_reload?: Flag;
  "daemon-reload"?: Flag;
};
export type ServiceArgs =
  | string
  | { name?: string; state?: string; enabled?: Flag };
export type AptArgs = {
  name?: Names;
  state?: string;
  update_cache?: Flag;
  deb?: string;
  cache_valid_time?: string | number;
  upgrade?: Flag;
  purge?: Flag;
  autoclean?: Flag;
  autoremove?: Flag;
  install_recommends?: Flag;
};
export type PackageArgs = string | { name?: Names; state?: string };
export type UserArgs = {
  name: string;
  home?: string;
  shell?: string;
  groups?: Names;
  group?: string;
  append?: Flag;
  create_home?: Flag;
  state?: string;
  password?: string;
  system?: Flag;
  generate_ssh_key?: Flag;
  remove?: string;
  uid?: string | number;
  non_unique?: Flag;
  password_lock?: Flag;
};
export type UriArgs = {
  url: string;
  return_content?: Flag;
  method?: string;
  user?: string;
  password?: string;
};
export type DebugArgs = string | { msg?: string; var?: string };
export type FailArgs = { msg: string };
export type StatArgs = { path: string };
export type ShellArgs = string | { cmd?: string };
export type SetFactArgs = string | Record<string, VarValue>;
export type GetUrlArgs = {
  url: string;
  dest: string;
  mode?: Mode;
  force?: Flag;
};
export type UnarchiveArgs = {
  src: string;
  dest: string;
  remote_src?: Flag;
  extra_opts?: string[];
  include?: string[];
  owner?: string;
  group?: string;
  mode?: Mode;
  creates?: string;
  list_files?: Flag;
};
export type PipArgs = string | {
  name?: Names;
  virtualenv?: string;
  state?: string;
  virtualenv_command?: string;
  requirements?: string;
};
export type BlockinfileArgs = {
  path: string;
  marker?: string;
  block?: string;
  create?: Flag;
  insertafter?: string;
  insertbefore?: string;
  state?: string;
  backup?: Flag;
  mode?: Mode;
};
export type LineinfileArgs = {
  path: string;
  line?: string;
  state?: string;
  regex?: string;
  regexp?: string;
  backrefs?: Flag;
  create?: Flag;
  insertafter?: string;
  insertbefore?: string;
  owner?: string;
  group?: string;
  mode?: Mode;
};
export type CronArgs = {
  name: string;
  job?: string;
  user?: string;
  hour?: string;
  minute?: string;
  state?: string;
  special_time?: string;
};
export type GitArgs = {
  repo: string;
  dest: string;
  version?: string;
  update?: Flag;
  force?: Flag;
  key_file?: string;
};
export type AuthorizedKeyArgs = {
  user: string;
  key: string;
  state?: string;
  key_options?: string;
  exclusive?: Flag;
};
