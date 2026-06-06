// Plays and playbooks. Plays and tasks are plain typed object literals
// (`satisfies Play[]`), so there is no wrapper noise — you write the data and
// TypeScript checks it.
import type { Host, HostPattern } from "../hosts.ts";
import type { Tmpl } from "../template.ts";
import type { Tags } from "./tags.ts";
import type { VarValue } from "./values.ts";
import type { Task } from "./task.ts";
import type { RoleBuilder } from "./role.ts";

export interface Play {
  /**
   * A single host/group; a YAML list of them (`Host[]`, rendered as a
   * sequence); or a space-separated `pattern(...)`.
   */
  hosts: Host | Host[] | HostPattern;
  tags?: Tags;
  vars?: Record<string, VarValue>;
  vars_files?: string | string[];
  pre_tasks?: Task[];
  roles?: RoleBuilder[];
  tasks?: Task[];
  handlers?: Task[];
  become?: boolean | Tmpl;
  become_user?: Tmpl;
  gather_facts?: boolean;
  connection?: Tmpl;
}

/** A playbook is an ordered list of plays. */
export type Playbook = Play[];

/**
 * A role task/handler file: a bare ordered list of tasks (no play wrapper),
 * loaded by Ansible via `import_tasks`/`include_role`/a role's `main.yml`.
 */
export type TaskFile = Task[];
