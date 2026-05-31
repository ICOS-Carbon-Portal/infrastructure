// Prove that every TypeScript playbook renders to YAML semantically identical to
// the original hand-written .yml in ../devops.
//
// "Semantically identical" = the two YAML documents parse to the same data
// structure (Ansible is insensitive to key order and to scalar-style choices
// like `yes` vs `true` or folded vs plain strings), so we compare parsed data,
// not text.
//
//   deno run --allow-all verify.ts
import { parse as parseYaml } from "npm:yaml@2";
import { render } from "./lib/ansible.ts";

// Ansible parses with PyYAML (YAML 1.1), where `yes`/`no`/`on`/`off` are
// booleans. npm:yaml defaults to 1.2, where they are plain strings. Parse both
// sides as 1.1 so the comparison reflects what Ansible actually sees.
const parse = (text: string): unknown => parseYaml(text, { version: "1.1" });

const playbooksDir = new URL("./playbooks/", import.meta.url);
const rolesDir = new URL("./roles/", import.meta.url);
const origDir = new URL("../devops/", import.meta.url);

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

// A unit to verify: a TS module and the original YAML it must reproduce.
type Unit = { label: string; ts: URL; yml: URL };

/**
 * Playbooks: playbooks/<rel>.ts ↔ ../devops/<rel>.yml. Recurses, so
 * playbooks/fixes/<n>.ts maps to ../devops/fixes/<n>.yml.
 */
async function collectPlaybooks(): Promise<Unit[]> {
  const units: Unit[] = [];
  async function walk(dir: URL, rel: string) {
    for await (const e of Deno.readDir(dir)) {
      const childRel = rel ? `${rel}/${e.name}` : e.name;
      if (e.isDirectory) {
        await walk(new URL(`${e.name}/`, dir), childRel);
      } else if (e.isFile && e.name.endsWith(".ts")) {
        const base = childRel.replace(/\.ts$/, "");
        units.push({
          label: base,
          ts: new URL(e.name, dir),
          yml: new URL(`${base}.yml`, origDir),
        });
      }
    }
  }
  await walk(playbooksDir, "");
  return units;
}

/** Role files: roles/<role>/{tasks,handlers}/<f>.ts ↔ ../devops/roles/<role>/{tasks,handlers}/<f>.yml */
async function collectRoles(): Promise<Unit[]> {
  const units: Unit[] = [];
  let roleEntries: Deno.DirEntry[];
  try {
    roleEntries = [];
    for await (const e of Deno.readDir(rolesDir)) roleEntries.push(e);
  } catch {
    return units; // roles/ not created yet
  }
  for (const role of roleEntries) {
    if (!role.isDirectory) continue;
    for (const sub of ["tasks", "handlers"]) {
      const subDir = new URL(`${role.name}/${sub}/`, rolesDir);
      try {
        for await (const f of Deno.readDir(subDir)) {
          if (!f.isFile || !f.name.endsWith(".ts")) continue;
          const base = f.name.replace(/\.ts$/, "");
          units.push({
            label: `${role.name}/${sub}/${base}`,
            ts: new URL(f.name, subDir),
            yml: new URL(`roles/${role.name}/${sub}/${base}.yml`, origDir),
          });
        }
      } catch { /* no such subdir */ }
    }
  }
  return units;
}

/**
 * Data files: data/<relpath>.ts ↔ ../devops/<relpath>.yml. The `data/` tree
 * mirrors the devops layout (roles/<r>/{meta,defaults,vars}, *.inventory,
 * host_vars, group_vars). Walked generically.
 */
async function collectData(): Promise<Unit[]> {
  const dataDir = new URL("./data/", import.meta.url);
  const units: Unit[] = [];
  async function walk(dir: URL, rel: string) {
    let entries: Deno.DirEntry[] = [];
    try {
      for await (const e of Deno.readDir(dir)) entries.push(e);
    } catch {
      return;
    }
    for (const e of entries) {
      const childRel = rel ? `${rel}/${e.name}` : e.name;
      if (e.isDirectory) {
        await walk(new URL(`${e.name}/`, dir), childRel);
      } else if (e.isFile && e.name.endsWith(".ts")) {
        const base = childRel.replace(/\.ts$/, "");
        units.push({
          label: `data/${base}`,
          ts: new URL(e.name, dir),
          yml: new URL(`${base}.yml`, origDir),
        });
      }
    }
  }
  await walk(dataDir, "");
  return units;
}

// Optional CLI args limit the run; an arg matches by full label, by basename, or
// as a substring (so `icos.cpauth` selects all of that role's files).
const args = Deno.args.map((a) => a.replace(/\.ts$/, ""));
const selected = (label: string): boolean => {
  if (args.length === 0) return true;
  const base = label.split("/").pop()!;
  return args.some((a) => label === a || base === a || label.includes(a));
};

const units = [
  ...await collectPlaybooks(),
  ...await collectRoles(),
  ...await collectData(),
]
  .filter((u) => selected(u.label))
  .sort((a, b) => a.label.localeCompare(b.label));

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
