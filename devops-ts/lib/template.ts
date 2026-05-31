// A value that carries a Jinja template (`{{ ... }}` / `{% ... %}`).
//
// Template values are produced by V / tmpl (and the per-role context accessors),
// and by wrapping a raw template string with tmpl("..."). The renderer emits any
// Template as a double-quoted scalar — so the "should this be quoted?" decision
// comes from the value's type, never from scanning its contents.

/** A Jinja template value. Renders as a quoted YAML scalar. */
export class Template {
  constructor(private readonly text: string) {}
  toString(): string {
    return this.text;
  }
}

/** A checked variable reference, e.g. `V.foo` — a Template holding "{{ foo }}". */
export type Ref = Template;

/** A field value that may be a plain string or a Jinja template. */
export type Tmpl = string | Template;

/**
 * Build a Template, either from a tagged template literal interpolating refs:
 *   tmpl`${V.nexus_home}/bbclient`     // "{{ nexus_home }}/bbclient"
 * or by wrapping a raw template string:
 *   tmpl("{{ item.src }}")             // "{{ item.src }}"
 */
export function tmpl(
  strings: TemplateStringsArray | string,
  ...refs: Array<Ref | string>
): Template {
  if (typeof strings === "string") return new Template(strings);
  const text = strings.reduce(
    (acc, part, i) => acc + part + (i < refs.length ? String(refs[i]) : ""),
    "",
  );
  return new Template(text);
}
