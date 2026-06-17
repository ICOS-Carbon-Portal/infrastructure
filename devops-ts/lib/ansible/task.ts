// A single Ansible task. Keyword fields (name, tags, when, …) are typed
// precisely so a raw-string `when`, a bad tag, or an unknown role name are
// caught; the action module itself is one extra key whose body falls through
// the index signature (Ansible has thousands of modules with ad-hoc shapes).
import type { Expr } from "../vars.ts";
import type { Roles } from "../roles.ts";
import type { Tmpl } from "../template.ts";
import type { Tags } from "./tags.ts";
import type { VarValue } from "./values.ts";
import type {
  AptArgs,
  AuthorizedKeyArgs,
  BlockinfileArgs,
  CopyArgs,
  CronArgs,
  DebugArgs,
  FailArgs,
  FileArgs,
  GetUrlArgs,
  GitArgs,
  LineinfileArgs,
  PackageArgs,
  PipArgs,
  ServiceArgs,
  SetFactArgs,
  ShellArgs,
  StatArgs,
  SystemdArgs,
  TemplateArgs,
  UnarchiveArgs,
  UriArgs,
  UserArgs,
} from "../modules.ts";

/**
 * A `when:` condition. A built `Expr` (never a raw string — build it with
 * isDefined/not/eq/and/etc.), or a list of them for YAML's list-form `when:`
 * where Ansible ANDs the entries.
 */
export type When = Expr | Expr[];

/** A role name: a known role from the registry. */
type RoleName = keyof Roles;

/**
 * A task. The keyword fields (name, tags, when, ...) are typed precisely — so a
 * raw-string `when`, a bad tag, or an unknown role name are caught. The action
 * module itself (shell, copy, lxd_container, ...) is one extra key whose body is
 * accepted as-is: Ansible has thousands of modules with ad-hoc argument shapes,
 * so they fall through the index signature rather than being enumerated.
 * `import_role`/`include_role` are typed because their `name` is a role.
 */
export interface Task {
  name?: Tmpl;
  tags?: Tags;
  when?: When;
  become?: boolean | Tmpl;
  become_user?: Tmpl;
  register?: string;
  notify?: Tmpl | Tmpl[];
  delegate_to?: Tmpl;
  run_once?: boolean;
  ignore_errors?: boolean;
  check_mode?: boolean;
  // Condition fields accept an `Expr` too, so register-result fields
  // (`r.failed`) and `not(...)` compose into them; arrays may mix the two
  // (an AND-list of `string` and `Expr` conditions).
  changed_when?: boolean | string | Expr | (string | Expr)[];
  failed_when?: boolean | string | Expr | (string | Expr)[];
  until?: string | Expr;
  loop?: Tmpl | VarValue[];
  loop_control?: Record<string, VarValue>;
  with_items?: Tmpl | VarValue[];
  block?: Task[];
  args?: Record<string, VarValue>;
  vars?: Record<string, VarValue>;

  // A bare `{ name }` (no other keys) is the common case; the fuller object adds
  // tasks_from etc. Both forms type the role name against the registry. Ansible
  // also accepts the free-form `name=<role>` string, but we always write the
  // object form (verify.ts treats the two as equivalent).
  import_role?: { name: RoleName; tasks_from?: string };
  include_role?: {
      name: RoleName;
      tasks_from?: string;
      apply?: { tags?: Tags };
      public?: boolean;
    };

  // Cross-file includes within a role: a sibling task file by name.
  import_tasks?: string;
  include_tasks?: string | { file: string; apply?: { tags?: Tags } };

  // Top modules: typed (a superset of real usage). FQCN aliases share the type.
  // Some accept Ansible's `key=value` string shorthand in addition to a mapping.
  file?: FileArgs | Tmpl;
  copy?: CopyArgs;
  "ansible.builtin.copy"?: CopyArgs;
  template?: TemplateArgs;
  "ansible.builtin.template"?: TemplateArgs;
  systemd?: SystemdArgs;
  service?: ServiceArgs;
  apt?: AptArgs;
  "ansible.builtin.package"?: PackageArgs;
  command?: Tmpl;
  shell?: ShellArgs;
  "ansible.builtin.shell"?: ShellArgs;
  debug?: DebugArgs;
  set_fact?: SetFactArgs;
  fail?: FailArgs;
  user?: UserArgs;
  uri?: UriArgs;
  stat?: StatArgs;
  get_url?: GetUrlArgs;
  "ansible.builtin.get_url"?: GetUrlArgs;
  unarchive?: UnarchiveArgs;
  pip?: PipArgs;
  "ansible.builtin.pip"?: PipArgs;
  blockinfile?: BlockinfileArgs;
  lineinfile?: LineinfileArgs;
  cron?: CronArgs;
  git?: GitArgs;
  authorized_key?: AuthorizedKeyArgs;

  // Any other key is an action module; its argument shape is module-specific.
  [module: string]: unknown;
}
