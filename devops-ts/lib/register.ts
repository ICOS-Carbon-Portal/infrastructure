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
// name becomes a "Cannot find name" compile error. String-valued fields are
// typed `PyStr` and expose the Python `str` methods used across the playbooks
// (`_r.stdout.endswith(V.podman_version)`), so those conditions no longer need
// raw() either.
import type { Expr } from "./vars.ts";
import { type Ref, Template, type VarRef } from "./template.ts";

/**
 * One field of a result holding a value of type `T`: an `Expr` (renders bare,
 * for when-positions — `failed_when: r.failed`) whose `.ref` is the
 * value-position reference (`{{ <path> }}`), a `VarRef<T>` so it both carries
 * the field's type (a `boolean` field's `.ref` fits a `boolean` arg) and exposes
 * the `Template` filter methods (`r.stdout.ref.first()`). `T` defaults to
 * `unknown` (a plain `Ref`) for fields not given a more specific type.
 */
export type Field<T = unknown> = Expr & { readonly ref: VarRef<T> };

/**
 * An argument to a Python string method: a string LITERAL (rendered `'quoted'`)
 * or a variable/expression reference (`V.x`, a register field) rendered bare.
 */
export type StrArg = string | Ref | Expr;

/**
 * A register result field that holds a Python string. Beyond the bare `Field`
 * (which renders the dotted path) it exposes the `str` methods used as Jinja
 * conditions across the playbooks; each renders `<path>.<method>(<args>)`:
 *
 *   _r.stdout.endswith(V.podman_version)   // _r.stdout.endswith(podman_version)
 *   _r.stderr.startswith("Created symlink")
 *   _r.msg.find("crontab")                  // an int — compare with eq/ne
 *   _r.stderr.lower()                       // a Python string (chainable)
 */
export interface PyStr extends Field<string> {
  endswith(suffix: StrArg): Expr;
  startswith(prefix: StrArg): Expr;
  /** Index of `sub` (or -1); compare with eq/ne. */
  find(sub: StrArg): Expr;
  lower(): PyStr;
}

/**
 * A register field holding a list of strings (`stdout_lines`). A numeric index
 * yields a `PyStr` rendered with Jinja bracket access, so the element's `str`
 * methods compose: `_r.stdout_lines[0].endswith(V.version)`.
 */
export interface PyStrList extends Field {
  [index: number]: PyStr;
}

/** A registered `.stat` sub-result (the `stat` module). */
export interface StatResult extends Expr {
  exists: Field<boolean>;
  isdir: Field<boolean>;
  checksum: Field<string>;
  uid: Field<number>;
  gid: Field<number>;
}

/** A registered `.status` sub-result (the `systemd` module's status dict). */
export interface SystemdStatus extends Field {
  ActiveState: Field<string>;
}

/** The common fields of an Ansible task result. */
export interface Result {
  changed: Field<boolean>;
  failed: Field<boolean>;
  rc: Field<number>;
  stdout: PyStr;
  stderr: PyStr;
  stdout_lines: PyStrList;
  status: SystemdStatus;
  msg: PyStr;
  dest: Field<string>;
  path: Field<string>;
  content: PyStr;
  backup_file: Field<string>;
  restart_required: Field<boolean>;
  stat: StatResult;
  // Module-specific result fields (user, github_release, lxd, find, ...).
  home: Field<string>;
  uid: Field<number>;
  group: Field<string>;
  ssh_public_key: Field<string>;
  tag: Field<string>;
  files: Field; // a list — left `unknown`
  ip: Field<string>;
  devices: Field; // a dict — left `unknown`
  addresses: { eth0: Field<string> };
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
/** Render a method argument: a string is a `'quoted'` literal; a ref/expr bare. */
function argText(a: unknown): string {
  if (typeof a === "string") return `'${a}'`;
  if (typeof a === "number" || typeof a === "boolean") return String(a);
  if (a instanceof Template) {
    const p = a.parts;
    if (p.length === 1 && p[0].kind === "ref") return p[0].jinja;
    if (p.length === 1 && p[0].kind === "raw") return p[0].text;
    return a.toText();
  }
  return String(a); // another register field / Expr
}

export function register(name: string): Reg {
  const node = (path: string): unknown =>
    new Proxy(function () {}, {
      get(_t, key) {
        if (
          key === "toJSON" || key === "toString" || key === Symbol.toPrimitive
        ) {
          return () => path;
        }
        // The value-position reference, "{{ <path> }}".
        if (key === "ref") return new Template([{ kind: "ref", jinja: path }]);
        const k = String(key);
        // A numeric key is Jinja list access (`stdout_lines[0]`,
        // `stdout_lines[-1]`), not `.0`.
        if (/^-?\d+$/.test(k)) return node(`${path}[${k}]`);
        return node(`${path}.${k}`);
      },
      // Method calls (`stdout.endswith(x)`) extend the path: `<path>(<args>)`.
      apply(_t, _this, args) {
        return node(`${path}(${args.map(argText).join(", ")})`);
      },
    });
  return node(name) as Reg;
}
