// A Jinja template value, built from STRUCTURED parts — literal string pieces
// and variable references — rather than a flat string that re-embeds `{{ }}`.
//
// Produced by:
//   V.foo                      // a ref part         -> {{ foo }}
//   expr("item.src")           // a ref part (escape) -> {{ item.src }}
//   tmpl`${V.foo}/bar`         // ref + literal parts -> {{ foo }}/bar
//   rawTmpl("{{nginxconfig}}") // a verbatim escape (exact bytes), for the few
//                              // awkward cases (non-canonical spacing, {% %},
//                              // Jinja escapes) that can't be cleanly structured
//
// The renderer emits any Template as a double-quoted scalar — quoting is decided
// by the value's TYPE, never by scanning a string for `{{`.

// Type-only (erased at runtime, so no circular dependency with vars.ts): the
// `when:` expression type, accepted as the condition of `iff()`.
import type { Expr } from "./vars.ts";

/** One piece of a template. */
export type Part =
  | { kind: "lit"; text: string } // literal text (must not contain `{{`/`{%`)
  | { kind: "ref"; jinja: string } // rendered as `{{ <jinja> }}` (canonical spacing)
  | { kind: "raw"; text: string }; // rendered EXACTLY as `text` (verbatim)

/**
 * A value usable as a Jinja filter argument (see `Template.default` etc.):
 * a single-ref Template renders as its bare expression (`V.x` -> `x`), a
 * boolean as Python `True`/`False`, a string as a `'...'` literal, an array
 * element-wise as `[...]`.
 */
export type FilterArg =
  | string
  | number
  | boolean
  | Template
  | ReadonlyArray<string | number | Template>;

function filterArgText(a: FilterArg): string {
  if (a instanceof Template) {
    const p = a.parts;
    if (p.length !== 1 || p[0].kind === "lit") {
      throw new Error(`composite template as a filter argument: "${a}"`);
    }
    return p[0].kind === "ref" ? p[0].jinja : p[0].text;
  }
  if (typeof a === "boolean") return a ? "True" : "False";
  if (typeof a === "number") return String(a);
  if (Array.isArray(a)) return `[${a.map(filterArgText).join(", ")}]`;
  return `'${a}'`;
}

/** A structured Jinja template value. */
export class Template {
  constructor(readonly parts: Part[]) {}

  /** The rendered Jinja text (literals verbatim, refs wrapped in `{{ }}`). */
  toText(): string {
    return this.parts
      .map((p) =>
        p.kind === "lit"
          ? p.text
          : p.kind === "raw"
          ? p.text
          : `{{ ${p.jinja} }}`
      )
      .join("");
  }
  toString(): string {
    return this.toText();
  }

  // --- filters ----------------------------------------------------------------
  // Chainable, each appending `| <filter>` (canonical spacing) to a single-ref
  // template: V.x.default(false).bool() -> {{ x | default(False) | bool }}.
  // Only the common filters are modelled; anything else stays an expr() escape.
  //
  // Grouped by origin: filters built into Jinja2 itself, and filters supplied by
  // Ansible's `ansible.builtin` filter plugins. (Functionally both are just
  // `| name(args)` in the rendered output; the split is documentation so a reader
  // knows which engine each one comes from.)

  /** Append `| <text>`; valid only on a single-ref template (V.x, expr(...)). */
  private filter(text: string): Template {
    const p = this.parts;
    if (p.length !== 1 || p[0].kind !== "ref") {
      throw new Error(`Jinja filter applied to a non-ref template: "${this}"`);
    }
    return new Template([{ kind: "ref", jinja: `${p[0].jinja} | ${text}` }]);
  }

  // -- Jinja2 built-in filters --
  /** `| default(...)`; pass `V.omit` for `default(omit)`, a ref for a var. */
  default(fallback: FilterArg): Template {
    return this.filter(`default(${filterArgText(fallback)})`);
  }
  /** `| int` — convert to an integer. */
  int(): Template {
    return this.filter("int");
  }
  /** `| lower` — lowercase a string. */
  lower(): Template {
    return this.filter("lower");
  }
  /** `| first` — the first element of a list. */
  first(): Template {
    return this.filter("first");
  }
  /** `| join(sep)` — join a list into a string. */
  join(sep: string): Template {
    return this.filter(`join('${sep}')`);
  }
  /** `| map(attribute='attr')` — pluck an attribute from each list item. */
  mapAttr(attr: string): Template {
    return this.filter(`map(attribute='${attr}')`);
  }

  // -- Ansible `ansible.builtin` filter plugins --
  // https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html#filter-plugins
  /** `| bool` — interpret a value (`"yes"`, `1`, ...) as a boolean. */
  bool(): Template {
    return this.filter("bool");
  }
  /** `| dirname` — the directory portion of a path. */
  dirname(): Template {
    return this.filter("dirname");
  }
  /** `| basename` — the final component of a path. */
  basename(): Template {
    return this.filter("basename");
  }
  /** `| splitext` — split a path into `(root, ext)`. */
  splitext(): Template {
    return this.filter("splitext");
  }
  /** `| b64decode` — decode a base64 string. */
  b64decode(): Template {
    return this.filter("b64decode");
  }
  /** `| combine(other)` — merge two dict-valued variables. */
  combine(other: Template): Template {
    return this.filter(`combine(${filterArgText(other)})`);
  }
  /** `| fileglob` — expand a glob to matching paths. */
  fileglob(): Template {
    return this.filter("fileglob");
  }
  /** `| difference(other)` — items in this list not in `other`. */
  difference(other: FilterArg): Template {
    return this.filter(`difference(${filterArgText(other)})`);
  }
  /** `| regex_replace(pattern, replacement)` — regex substitution. */
  regexReplace(pattern: string, replacement: string): Template {
    return this.filter(`regex_replace('${pattern}', '${replacement}')`);
  }
  /**
   * `| password_hash(scheme[, salt])` — hash a password with crypt. `scheme` is
   * a crypt method like `"sha512"`; `salt` is an optional ref/literal salt.
   */
  passwordHash(scheme: string, salt?: FilterArg): Template {
    const args = salt === undefined
      ? `'${scheme}'`
      : `'${scheme}', ${filterArgText(salt)}`;
    return this.filter(`password_hash(${args})`);
  }

  /**
   * Python string methods usable in Jinja value expressions:
   *   gh.tag.ref.lstrip("v")   // {{ gh.tag.lstrip('v') }}
   */
  lstrip(chars: string): Template {
    return this.method(`lstrip('${chars}')`);
  }
  rstrip(chars: string): Template {
    return this.method(`rstrip('${chars}')`);
  }
  /** `.strip()` — strip leading/trailing whitespace. */
  strip(): Template {
    return this.method("strip()");
  }
  /** `.split(sep)` — split a string into a list (pass `"\\n"` for a newline). */
  split(sep: string): Template {
    return this.method(`split('${sep}')`);
  }
  private method(call: string): Template {
    const p = this.parts;
    if (p.length !== 1 || p[0].kind !== "ref") {
      throw new Error(`Jinja method call on a non-ref template: "${this}"`);
    }
    return new Template([{ kind: "ref", jinja: `${p[0].jinja}.${call}` }]);
  }

  /**
   * Checked `[key]` index access on a map-valued variable:
   *   V.borg_url_map.at(V.ansible_architecture)  // {{ borg_url_map[ansible_architecture] }}
   */
  at(key: Template | string | number): Template {
    const p = this.parts;
    if (p.length !== 1 || p[0].kind !== "ref") {
      throw new Error(`index access on a non-ref template: "${this}"`);
    }
    return new Template([
      { kind: "ref", jinja: `${p[0].jinja}[${filterArgText(key)}]` },
    ]);
  }
}

/**
 * A nested variable reference: a single-ref `Template` whose property access
 * yields a deeper reference (`varProxy("a").b` -> `{{ a.b }}`). This is the
 * runtime behind `V.x.y` for object-shaped variables (lib/shapes.ts) — the
 * TYPE (`VarRef`) decides which fields exist; the proxy serves any of them.
 * `Template`'s own members (parts, filters, `at`) pass through to the base.
 */
export function varProxy(path: string): Ref {
  const base = new Template([{ kind: "ref", jinja: path }]);
  return new Proxy(base, {
    get(target, key, receiver) {
      if (typeof key === "symbol" || key in target) {
        return Reflect.get(target, key, receiver);
      }
      return varProxy(`${path}.${String(key)}`);
    },
  });
}

/**
 * The reference type for a variable declared as `T`: a plain `Ref` for scalar
 * variables, a `Ref` that also exposes per-field refs for object-shaped ones
 * (see lib/shapes.ts). `[T] extends [object]` (no distribution) so unions and
 * `unknown` stay plain `Ref`s.
 */
export type VarRef<T> = [T] extends [object]
  ? Ref & { readonly [K in keyof T]-?: VarRef<T[K]> }
  : Ref;

/**
 * A verbatim template escape: renders its exact text (incl. braces/spacing).
 * A distinct, greppable type for the awkward cases that can't be structured —
 * non-canonical spacing, `{% %}` statements, Jinja escapes. Audit with
 * `grep -r 'rawTmpl('`.
 */
export class RawTemplate extends Template {
  constructor(text: string) {
    super([{ kind: "raw", text }]);
  }
}

/** A checked variable reference, e.g. `V.foo` — a single-ref Template. */
export type Ref = Template;

/** A field value that may be a plain string or a Jinja template. */
export type Tmpl = string | Template;

/** Reference a dynamic variable / arbitrary Jinja value expression: `{{ jinja }}`. */
export function expr(jinja: string): Template {
  return new Template([{ kind: "ref", jinja }]);
}

/**
 * A Jinja conditional value expression: `iff(c, a, b)` -> `{{ A if C else B }}`.
 *
 * The condition renders bare — pass a `when:`-style `Expr` (`eq`/`isIn`, `and`/
 * `or`, a register field like `_r.changed`) or a single-ref `Template` (`V.x`).
 * The branches are filter-args: a string becomes a `'quoted'` Jinja literal,
 * `V.x` / `V.omit` render bare, numbers and booleans as-is.
 *
 *   iff(V.caddy_upgrade, "latest", "present")     // {{ 'latest' if caddy_upgrade else 'present' }}
 *   iff(eq(V.where, "EOF"), "EOF", V.omit)        // {{ 'EOF' if where == 'EOF' else omit }}
 *
 * Replaces the stringly-typed `expr("'a' if cond else 'b'")`: the branches are
 * type-checked, and a `V.x`/register condition is checked too.
 */
export function iff(
  cond: Expr | Template,
  then: FilterArg,
  otherwise: FilterArg,
): Template {
  const c = cond instanceof Template ? filterArgText(cond) : String(cond);
  return new Template([{
    kind: "ref",
    jinja: `${filterArgText(then)} if ${c} else ${filterArgText(otherwise)}`,
  }]);
}

/** Verbatim template escape for awkward cases (see RawTemplate). */
export function rawTmpl(text: string): RawTemplate {
  return new RawTemplate(text);
}

/**
 * An Ansible `lookup(...)` value expression. The plugin name is a closed union
 * (a typo is a compile error; add a plugin here before using it); each argument
 * is a filter-arg — a string becomes a `'quoted'` literal, a `V.x` ref renders
 * bare (for `lookup('vars', some_var)`).
 *
 *   lookup("template", "borgmon.py")  // {{ lookup('template', 'borgmon.py') }}
 *   lookup("vars", V.set_fact)         // {{ lookup('vars', set_fact) }}
 *
 * A trailing plain-object argument is rendered as Jinja keyword arguments:
 *
 *   lookup("vars", V.set_fact, { default: false })
 *     // {{ lookup('vars', set_fact, default=False) }}
 *
 * Replaces `expr("lookup('template', '...')")`.
 */
export type LookupPlugin = "template" | "file" | "env" | "vars" | "pipe";

type LookupKwargs = Record<string, FilterArg>;

export function lookup(
  plugin: LookupPlugin,
  ...args: (FilterArg | LookupKwargs)[]
): Template {
  // A trailing plain object (not a Template/array/primitive) is keyword args.
  let kwargs: LookupKwargs | undefined;
  const last = args[args.length - 1];
  if (
    last !== null && typeof last === "object" && !Array.isArray(last) &&
    !(last instanceof Template)
  ) {
    kwargs = args.pop() as LookupKwargs;
  }
  const parts = [
    filterArgText(plugin),
    ...(args as FilterArg[]).map(filterArgText),
  ];
  if (kwargs) {
    for (const [k, v] of Object.entries(kwargs)) {
      parts.push(`${k}=${filterArgText(v)}`);
    }
  }
  return new Template([{ kind: "ref", jinja: `lookup(${parts.join(", ")})` }]);
}

/**
 * A Jinja `+` expression: `concat(a, b, ...)` -> `{{ a + b + ... }}`. Each part
 * is a filter-arg, so a `V.x` ref renders bare and a string becomes a `'quoted'`
 * literal. Used for list/string concatenation in value position.
 *
 *   concat(V.jupyter_domains, V.ganymede_domains)  // {{ jupyter_domains + ganymede_domains }}
 */
export function concat(...parts: FilterArg[]): Template {
  return new Template([
    { kind: "ref", jinja: parts.map(filterArgText).join(" + ") },
  ]);
}

/**
 * Python `%` string formatting: `pct(fmt, arg)` -> `{{ '<fmt>' % <arg> }}`. The
 * format is a single-quoted literal; the argument is a filter-arg (a `V.x` ref
 * renders bare). Replaces `expr("'pkg-%s' % version")`.
 *
 *   pct("postgresql-%s", V.postgresql_version)  // {{ 'postgresql-%s' % postgresql_version }}
 */
export function pct(fmt: string, arg: FilterArg): Template {
  return new Template([
    { kind: "ref", jinja: `'${fmt}' % ${filterArgText(arg)}` },
  ]);
}

/**
 * The Jinja2 `random` filter with a deterministic seed, over an integer upper
 * bound: `randomInt(max, seed)` -> `{{ <max> | random(seed='<seed>') }}` (a
 * stable pseudo-random int in `[0, max)`). Replaces
 * `expr("4 | random(seed='x')")` (e.g. spreading cron jobs across hosts).
 */
export function randomInt(max: number, seed: string): Template {
  return new Template([
    { kind: "ref", jinja: `${max} | random(seed='${seed}')` },
  ]);
}

/**
 * A typed reference to a task-local variable (one bound in a task's `vars:`):
 * `localVar<{image: string}>("conf").image` -> `{{ conf.image }}`. The shape `T`
 * names the fields the playbook accesses; the proxy serves any of them. This is
 * the task-`vars:` counterpart of `V.x` (globals) and the loop `item` proxy.
 */
export function localVar<T>(name: string): VarRef<T> {
  return varProxy(name) as unknown as VarRef<T>;
}

/**
 * A Jinja `{% for %}` loop rendered as a verbatim fragment. `body` receives a
 * typed reference to the loop variable; the iterable is a checked ref. Replaces
 * the `rawTmpl("{% for x in y %}")` / `expr("x")` / `rawTmpl("{% endfor %}")`
 * trio with one construct whose iterable and loop-var references are checked.
 *
 *   jinjaFor<string>("module", V.caddy_modules, (m) => tmpl` --with ${m} `)
 *   // {% for module in caddy_modules %} --with {{ module }} {% endfor %}
 */
export function jinjaFor<T>(
  loopVar: string,
  iterable: Template,
  body: (item: VarRef<T>) => Template,
): RawTemplate {
  const p = iterable.parts;
  const iter = p.length === 1 && p[0].kind === "ref"
    ? p[0].jinja
    : iterable.toText();
  const bodyText = body(varProxy(loopVar) as VarRef<T>).toText();
  return new RawTemplate(
    `{% for ${loopVar} in ${iter} %}${bodyText}{% endfor %}`,
  );
}

/**
 * Build a Template from a tagged template literal, splicing interpolated refs:
 *   tmpl`${V.nexus_home}/bbclient`     // {{ nexus_home }}/bbclient
 *
 * Tagged-only by design: a templated value is structured (literal parts + refs),
 * never a flat string with embedded `{{ }}`. For a dynamic ref use `expr(...)`;
 * for an awkward verbatim case use `rawTmpl(...)`.
 */
export function tmpl(
  strings: TemplateStringsArray,
  ...refs: Array<Template | string>
): Template {
  const parts: Part[] = [];
  const pushLit = (text: string) => {
    if (!text) return;
    const last = parts[parts.length - 1];
    if (last?.kind === "lit") last.text += text;
    else parts.push({ kind: "lit", text });
  };
  strings.forEach((s, i) => {
    pushLit(s);
    if (i < refs.length) {
      const r = refs[i];
      if (typeof r === "string") pushLit(r);
      else if (r instanceof Template) parts.push(...r.parts); // splice refs
      else pushLit(String(r)); // ref-like (e.g. loop `item` proxy) -> verbatim text
    }
  });
  return new Template(parts);
}
