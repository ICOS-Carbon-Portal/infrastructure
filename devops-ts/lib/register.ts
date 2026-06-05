// Typed `register:` result handles.
//
// A task `register:`s its result under a name, and later tasks reference fields
// of it (`_r.changed`, `_r.stdout`, `_r.stat.exists`) in when/failed_when/etc.
// Written as raw strings those references are unchecked — a typo in the name
// (`_rr.changed`) or a field (`_r.chnaged`) is silently undefined in Ansible.
//
// `register("_r")` returns a handle that:
//   * is usable directly in `register:` (renders the name "_r"),
//   * exposes the common result fields as `Expr`s for condition positions:
//       register: r,  failed_when: r.failed,  until: not(r.failed)
//   * and, via `.ref`, as checked `Template`s for VALUE positions:
//       dest: tmpl`${r.dest.ref}/bin/btop`   // "{{ r.dest }}/bin/btop"
//
// Declare it once as a `const` and reference it across tasks, so an unregistered
// name becomes a "Cannot find name" compile error. Complex expressions over a
// result (`_r.stdout.startswith(...)`) stay raw — only field access is modelled.
import type { Expr } from "./vars.ts";
import { expr, type Ref } from "./template.ts";

/**
 * One field of a result: an `Expr` (renders bare, for when-positions) whose
 * `.ref` is the value-position `Template` reference ("{{ <path> }}"). The
 * `Template` filter methods are then available: `r.stdout.ref.first()`.
 */
export type Field = Expr & { readonly ref: Ref };

/** A registered `.stat` sub-result (the `stat` module). */
export interface StatResult extends Expr {
  exists: Field;
  isdir: Field;
  checksum: Field;
}

/** The common fields of an Ansible task result. */
export interface Result {
  changed: Field;
  failed: Field;
  rc: Field;
  stdout: Field;
  stderr: Field;
  stdout_lines: Field;
  status: Field;
  msg: Field;
  dest: Field;
  path: Field;
  content: Field;
  backup_file: Field;
  restart_required: Field;
  stat: StatResult;
  // Module-specific result fields (user, github_release, lxd, find, ...).
  home: Field;
  uid: Field;
  group: Field;
  ssh_public_key: Field;
  tag: Field;
  files: Field;
  ip: Field;
  addresses: { eth0: Field };
}

/** A `register:` handle: the name string plus typed result-field accessors. */
export type Reg = string & Result & { readonly ref: Ref };

/**
 * Build a registered-result handle for `name`. Each field access returns a
 * deeper node (so `r.stat.exists` works); every node renders to its dotted path
 * via `toJSON` (all the when-position renderer needs), and `.ref` yields the
 * value-position `Template`. The static type (`Reg`, `Result`, `Field`) is
 * supplied by the cast.
 */
export function register(name: string): Reg {
  const node = (path: string): unknown =>
    new Proxy(function () {}, {
      get(_t, key) {
        if (
          key === "toJSON" || key === "toString" || key === Symbol.toPrimitive
        ) {
          return () => path;
        }
        if (key === "ref") return expr(path);
        return node(`${path}.${String(key)}`);
      },
    });
  return node(name) as Reg;
}
