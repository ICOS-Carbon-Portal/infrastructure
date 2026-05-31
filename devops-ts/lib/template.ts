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

/** One piece of a template. */
export type Part =
  | { kind: "lit"; text: string } // literal text (must not contain `{{`/`{%`)
  | { kind: "ref"; jinja: string } // rendered as `{{ <jinja> }}` (canonical spacing)
  | { kind: "raw"; text: string }; // rendered EXACTLY as `text` (verbatim)

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
}

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

/** Verbatim template escape for awkward cases (see RawTemplate). */
export function rawTmpl(text: string): RawTemplate {
  return new RawTemplate(text);
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
