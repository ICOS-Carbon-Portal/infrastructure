// Render a typed playbook / task file back to YAML, byte-faithful to the
// hand-written `.yml` (verified by verify.ts).
import { Expr } from "../vars.ts";
import { Template } from "../template.ts";
import type { Playbook, TaskFile } from "./play.ts";

/**
 * Render a playbook or a role task file to YAML identical (semantically) to the
 * hand-written `.yml`.
 *
 * Rather than JSON-flattening (which would erase the Template/Expr wrappers),
 * it walks the object graph: `Template` values become double-quoted scalars
 * (that's the type-driven quoting — a value is quoted because it IS a template,
 * not because its text contains `{{`), `Expr` (when-conditions) and builders
 * with `toJSON` collapse to their plain form, and `undefined` keys are dropped.
 */
export async function render(doc: Playbook | TaskFile): Promise<string> {
  const { Document, Scalar } = await import("yaml");

  // deno-lint-ignore no-explicit-any
  function clean(v: any): unknown {
    if (v === null || v === undefined) return v;
    if (v instanceof Template) {
      const s = new Scalar(v.toText()); // join structured parts (refs -> {{ }})
      s.type = "QUOTE_DOUBLE"; // type-driven quoting
      return s;
    }
    if (v instanceof Expr) return v.toString(); // when-conditions render bare
    if (Array.isArray(v)) {
      return v.map(clean).filter((x) => x !== undefined);
    }
    if (typeof v === "object") {
      // RoleBuilder and similar expose their YAML shape via toJSON().
      if (typeof v.toJSON === "function") return clean(v.toJSON());
      const out: Record<string, unknown> = {};
      for (const [k, val] of Object.entries(v)) {
        const c = clean(val);
        if (c !== undefined) out[k] = c;
      }
      return out;
    }
    return v;
  }

  // Emit YAML 1.1 (like Ansible's PyYAML) so string scalars that look like 1.1
  // booleans — "yes"/"no"/"on"/"off" — are quoted rather than emitted bare.
  const document = new Document(clean(doc), { version: "1.1" });
  // Ansible's hand-written YAML leaves null mapping values empty (`key:`) rather
  // than spelling out `key: null`; match that so the rendered output is
  // byte-faithful to the originals (both parse to null either way).
  return document.toString({ lineWidth: 0, nullStr: "" });
}
