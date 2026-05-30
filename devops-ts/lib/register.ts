// Typed `register:` result handles.
//
// A task `register:`s its result under a name, and later tasks reference fields
// of it (`_r.changed`, `_r.stdout`, `_r.stat.exists`) in when/failed_when/etc.
// Written as raw strings those references are unchecked — a typo in the name
// (`_rr.changed`) or a field (`_r.chnaged`) is silently undefined in Ansible.
//
// `register("_r")` returns a handle that:
//   * is usable directly in `register:` (renders the name "_r"), and
//   * exposes the common result fields as `Expr`s for condition positions:
//       register: r,  failed_when: r.failed,  until: not(r.failed)
//
// Declare it once as a `const` and reference it across tasks, so an unregistered
// name becomes a "Cannot find name" compile error. Complex expressions over a
// result (`_r.stdout.startswith(...)`) stay raw — only field access is modelled.
import type { Expr } from "./vars.ts";

/** A registered `.stat` sub-result (the `stat` module). */
export interface StatResult extends Expr {
  exists: Expr;
  isdir: Expr;
}

/** The common fields of an Ansible task result. */
export interface Result {
  changed: Expr;
  failed: Expr;
  rc: Expr;
  stdout: Expr;
  stderr: Expr;
  stdout_lines: Expr;
  status: Expr;
  msg: Expr;
  dest: Expr;
  path: Expr;
  content: Expr;
  backup_file: Expr;
  stat: StatResult;
}

/** A `register:` handle: the name string plus typed result-field accessors. */
export type Reg = string & Result;

/**
 * Build a registered-result handle for `name`. Each field access returns a
 * deeper node (so `r.stat.exists` works); every node renders to its dotted path
 * via `toJSON`, which is all the renderer needs. The static type (`Reg`,
 * `Result`, `Expr`) is supplied by the cast.
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
        return node(`${path}.${String(key)}`);
      },
    });
  return node(name) as Reg;
}
