// Prove that every TypeScript playbook renders to YAML semantically identical to
// the original hand-written .yml in ../devops.
//
// "Semantically identical" = the two YAML documents parse to the same data
// structure (Ansible is insensitive to key order and to scalar-style choices
// like `yes` vs `true` or folded vs plain strings), so we compare parsed data,
// not text.
//
//   deno run --allow-all verify.ts
import { parse as parseYaml } from "yaml";
import { render } from "./lib/ansible.ts";
import { collectUnits } from "./lib/units.ts";

// Ansible parses with PyYAML (YAML 1.1), where `yes`/`no`/`on`/`off` are
// booleans. npm:yaml defaults to 1.2, where they are plain strings. Parse both
// sides as 1.1 so the comparison reflects what Ansible actually sees.
const parse = (text: string): unknown => parseYaml(text, { version: "1.1" });

/** Recursively compare parsed YAML; returns the first differing path, or null. */
function diff(a: unknown, b: unknown, path = "$"): string | null {
  if (a === b) return null;
  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) {
      return `${path}: array length ${a.length} ≠ ${b.length}`;
    }
    for (let i = 0; i < a.length; i++) {
      const d = diff(a[i], b[i], `${path}[${i}]`);
      if (d) return d;
    }
    return null;
  }
  if (isObject(a) && isObject(b)) {
    const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
    for (const k of keys) {
      if (!(k in a)) return `${path}.${k}: missing on rendered side`;
      if (!(k in b)) return `${path}.${k}: extra on rendered side`;
      const d = diff(a[k], b[k], `${path}.${k}`);
      if (d) return d;
    }
    return null;
  }
  return `${path}: ${JSON.stringify(a)} ≠ ${JSON.stringify(b)}`;
}

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

// Optional CLI args limit the run; an arg matches by full label, by basename, or
// as a substring (so `icos.cpauth` selects all of that role's files).
const args = Deno.args.map((a) => a.replace(/\.ts$/, ""));
const selected = (label: string): boolean => {
  if (args.length === 0) return true;
  const base = label.split("/").pop()!;
  return args.some((a) => label === a || base === a || label.includes(a));
};

const units = (await collectUnits()).filter((u) => selected(u.label));

let pass = 0;
let fail = 0;
for (const unit of units) {
  let original: unknown;
  try {
    original = parse(await Deno.readTextFile(unit.yml));
  } catch {
    console.log(`SKIP ${unit.label} (no original)`);
    continue;
  }

  try {
    const mod = await import(unit.ts.href);
    const rendered = parse(await render(mod.default));
    const d = diff(rendered, original);
    if (d) {
      console.log(`FAIL ${unit.label} (${d})`);
      fail++;
    } else {
      console.log(`OK   ${unit.label}`);
      pass++;
    }
  } catch (e) {
    console.log(`FAIL ${unit.label} (${e instanceof Error ? e.message : e})`);
    fail++;
  }
}

console.log(`\nVerify: ${pass} passed, ${fail} failed`);
Deno.exit(fail === 0 ? 0 : 1);
