// Barrel for the strongly-typed Ansible model used by the top-level playbooks
// and role task files. The model itself lives in focused modules under
// `lib/ansible/` (tags, task, role, play, render, values); this file just
// re-exports them — together with the variable/host/loop/register/template
// helpers — so a playbook or role file imports everything from one place.
//
// The goal is to emit byte-for-byte equivalent YAML (semantically — Ansible is
// insensitive to key order) while catching typos and structural mistakes at the
// type level. Plays and tasks are plain typed object literals (`satisfies
// Play[]`); only roles go through a builder (`role()`), which unlocks per-role
// parameter typing keyed off the role name.

// --- Variables, hosts, loops, registers, templates ------------------------
export {
  and,
  eq,
  Expr,
  group,
  gt,
  gte,
  hostvar,
  isDefined,
  isIn,
  isNotDefined,
  isTruthy,
  isUndefined,
  isVersion,
  lt,
  lte,
  ne,
  not,
  notIn,
  type Operand,
  or,
  type Ref,
  type Subject,
  tmpl,
  truthy,
  V,
  varByName,
  type Vars,
} from "./vars.ts";
export { type Host, type HostPattern, pattern } from "./hosts.ts";
export type { BuiltinVars } from "./builtins.ts";
export {
  type Item,
  type LoopOpts,
  loopOver,
  loopOverVar,
  withItemsOver,
  withItemsOverVar,
} from "./loop.ts";
export { type Reg, register, type Result } from "./register.ts";
export {
  concat,
  iff,
  jinja,
  jinjaFor,
  jinjaLiteral,
  localVar,
  lookup,
  type LookupPlugin,
  pct,
  randomInt,
  RawTemplate,
  Template,
  /**
   * A value that may be a plain string or a Jinja template (`V.x`, `tmpl(...)`).
   * Template-typed values render as quoted YAML scalars.
   */
  type Tmpl,
} from "./template.ts";

// --- The Ansible model (lib/ansible/) -------------------------------------
export type { Tag, Tags } from "./ansible/tags.ts";
export type { Task, When } from "./ansible/task.ts";
export {
  role,
  RoleBuilder,
  type RoleOpts,
  type RoleRef,
} from "./ansible/role.ts";
export type { Scalar, VarValue } from "./ansible/values.ts";
export type { Play, Playbook, TaskFile } from "./ansible/play.ts";
export { render } from "./ansible/render.ts";
