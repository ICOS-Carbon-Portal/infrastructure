// Enumerates every TS module that renders to a devops YAML file, with the
// devops-relative path it maps to. Shared by verify.ts (compare) and
// render-all.ts (write). One source of truth for the .ts ↔ .yml mapping.

const root = new URL("../", import.meta.url); // devops-ts/
const playbooksDir = new URL("playbooks/", root);
const rolesDir = new URL("roles/", root);
const dataDir = new URL("data/", root);
const origDir = new URL("../devops/", root);

/** A renderable unit: its TS module, the original YAML, and the devops-relative path. */
export type Unit = {
  kind: "playbook" | "role" | "data";
  label: string;
  ts: URL;
  yml: URL;
  rel: string;
};

/**
 * Playbooks: playbooks/<rel>.ts → <rel>.yml (recurses, so playbooks/fixes/<n>.ts
 * → fixes/<n>.yml).
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
          kind: "playbook",
          label: base,
          ts: new URL(e.name, dir),
          yml: new URL(`${base}.yml`, origDir),
          rel: `${base}.yml`,
        });
      }
    }
  }
  await walk(playbooksDir, "");
  return units;
}

/** Role files: roles/<role>/{tasks,handlers}/<f>.ts → roles/<role>/{tasks,handlers}/<f>.yml */
async function collectRoles(): Promise<Unit[]> {
  const units: Unit[] = [];
  let roleEntries: Deno.DirEntry[] = [];
  try {
    for await (const e of Deno.readDir(rolesDir)) roleEntries.push(e);
  } catch {
    return units;
  }
  for (const role of roleEntries) {
    if (!role.isDirectory) continue;
    for (const sub of ["tasks", "handlers"]) {
      const subDir = new URL(`${role.name}/${sub}/`, rolesDir);
      try {
        for await (const f of Deno.readDir(subDir)) {
          if (!f.isFile || !f.name.endsWith(".ts")) continue;
          const base = f.name.replace(/\.ts$/, "");
          const rel = `roles/${role.name}/${sub}/${base}.yml`;
          units.push({
            kind: "role",
            label: `${role.name}/${sub}/${base}`,
            ts: new URL(f.name, subDir),
            yml: new URL(rel, origDir),
            rel,
          });
        }
      } catch { /* no such subdir */ }
    }
  }
  return units;
}

/** Data files: data/<rel>.ts → <rel>.yml (data/ mirrors the devops layout). */
async function collectData(): Promise<Unit[]> {
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
          kind: "data",
          label: `data/${base}`,
          ts: new URL(e.name, dir),
          yml: new URL(`${base}.yml`, origDir),
          rel: `${base}.yml`,
        });
      }
    }
  }
  await walk(dataDir, "");
  return units;
}

/** All renderable units, sorted by label. */
export async function collectUnits(): Promise<Unit[]> {
  return [
    ...await collectPlaybooks(),
    ...await collectRoles(),
    ...await collectData(),
  ].sort((a, b) => a.label.localeCompare(b.label));
}
