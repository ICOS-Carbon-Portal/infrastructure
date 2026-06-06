// Generate per-role variable contexts: roles/<role>/_ctx.ts
//
// Reads each role's ../devops/roles/<role>/{defaults,vars}/*.yml, collects the
// top-level variable names, and emits a `Vars` interface + a `context<...>()`
// accessor. The context is widened with ONLY the registries the role's task
// and handler files actually reference (scanned for `V.x` / `isDef("x")` /
// `notVar("x")`), so each _ctx.ts carries the smallest type that still checks.
// Idempotent; re-run after editing role defaults or converting tasks.
//
//   deno run --allow-read --allow-write gen-contexts.ts
import { parse } from "yaml";

const devopsRoles = new URL("../devops/roles/", import.meta.url);
const tsRoles = new URL("./roles/", import.meta.url);

/** Interface member names declared in a lib file (to avoid intersection clashes). */
async function declaredNames(path: string): Promise<Set<string>> {
  const names = new Set<string>();
  const text = await Deno.readTextFile(new URL(path, import.meta.url));
  for (const m of text.matchAll(/^\s{2}([A-Za-z_$][\w$]*)\??:/gm)) {
    names.add(m[1]);
  }
  return names;
}

const GLOBALS = await declaredNames("./lib/globals.ts");
const BUILTINS = await declaredNames("./lib/builtins.ts");
const PARAMVARS = await declaredNames("./lib/paramvars.ts");
const VAULTVARS = await declaredNames("./lib/vaultvars.ts");
const SHAPES = await declaredNames("./lib/shapes.ts");

// A role's own var that is also a global/builtin would make `Vars & Globals &
// BuiltinVars` collide (e.g. boolean & string -> never), so own vars exclude them;
// they remain reachable through the widening with the global/builtin type.
const reserved = new Set([...GLOBALS, ...BUILTINS]);

// Infer a TS type for a default VALUE — the type the generated data file (which
// `satisfies Vars`) must also produce. A scalar is concrete (`string`/`number`/
// `boolean`/`null`); a TEMPLATED string is emitted as a `Template`, so it is
// typed `Tmpl` (= string | Template), which also keeps `VarRef<Tmpl>` a plain
// Ref (a union that isn't `extends object`); maps/lists recurse. Shaped names
// (lib/shapes.ts) stay `unknown` so the hand-declared object shape still wins the
// `Vars & VarShapes` intersection (`unknown & Shape = Shape`); globals/builtins
// are already excluded from Vars (`reserved`), so no `concrete & string = never`.
const isTemplated = (s: string) => s.includes("{{") || s.includes("{%");
function unifyTypes(types: string[]): string {
  const set = [...new Set(types)];
  if (set.length === 1) return set[0];
  if (set.every((t) => t === "string" || t === "Tmpl")) return "Tmpl";
  return "VarValue";
}
function inferType(v: unknown): string {
  if (v === null) return "null";
  const t = typeof v;
  if (t === "boolean") return "boolean";
  if (t === "number") return "number";
  if (t === "string") return isTemplated(v as string) ? "Tmpl" : "string";
  // Arrays stay `unknown`: `VarRef<T[]>` intersects the array's `filter` with
  // Template's PRIVATE `filter`, collapsing the whole ref to `never`. Records
  // are fine — they add an index signature, not a conflicting named member.
  if (Array.isArray(v)) return "unknown";
  if (t === "object") {
    const vals = Object.values(v as Record<string, unknown>);
    if (vals.length === 0) return "Record<string, VarValue>";
    return `Record<string, ${unifyTypes(vals.map(inferType))}>`;
  }
  return "unknown";
}
function tsType(name: string, v: unknown): string {
  // Keep `unknown` for any name another widened registry types concretely, so
  // the `Vars & ...` intersection can't collapse to `never` (e.g. a default of
  // `null`/`number` for a name ParamVars/VaultVars declare `string`). Shaped
  // names keep `unknown` so the hand-written object shape wins. Globals/builtins
  // are already excluded from Vars (`reserved`).
  if (
    SHAPES.has(name) || PARAMVARS.has(name) || VAULTVARS.has(name) ||
    GLOBALS.has(name) || BUILTINS.has(name)
  ) {
    return "unknown";
  }
  return inferType(v);
}

/** A valid bare TS identifier needs no quoting as an interface key. */
const ident = /^[A-Za-z_$][A-Za-z0-9_$]*$/;

// ---------------------------------------------------------------------------
// Pass 1: collect every role's own variable names (defaults/vars yml). The
// full set is needed before emitting any context, to attribute cross-role
// references when computing the shared-vars surface.
// ---------------------------------------------------------------------------
const roleVars = new Map<string, Map<string, string>>(); // role -> name -> type
for await (const role of Deno.readDir(devopsRoles)) {
  if (!role.isDirectory) continue;

  const vars = new Map<string, string>();
  for (const sub of ["defaults", "vars"]) {
    const dir = new URL(`${role.name}/${sub}/`, devopsRoles);
    const entries: Deno.DirEntry[] = [];
    try {
      for await (const f of Deno.readDir(dir)) entries.push(f);
    } catch {
      continue;
    }
    for (const f of entries) {
      if (!f.isFile || !f.name.endsWith(".yml")) continue;
      let doc: unknown;
      try {
        // YAML 1.1 (matching gen-data + verify), so `yes`/`no` infer as
        // `boolean`, not the strings "yes"/"no".
        doc = parse(await Deno.readTextFile(new URL(f.name, dir)), {
          version: "1.1",
        });
      } catch {
        continue;
      }
      if (doc && typeof doc === "object" && !Array.isArray(doc)) {
        for (const [k, v] of Object.entries(doc as Record<string, unknown>)) {
          if (reserved.has(k)) continue; // covered by Globals/BuiltinVars widening
          if (!vars.has(k) || vars.get(k) === "unknown") {
            vars.set(k, tsType(k, v));
          }
        }
      }
    }
  }
  roleVars.set(role.name, vars);
}

// Every var name defined in ANY role's defaults/vars — used to attribute
// cross-role references when building the shared-vars surface below.
const allVars = new Set<string>();
for (const vars of roleVars.values()) {
  for (const name of vars.keys()) allVars.add(name);
}

// ---------------------------------------------------------------------------
// Pass 2: emit each role's _ctx.ts, widened with only the registries its task
// and handler files actually use.
// ---------------------------------------------------------------------------

/**
 * Variable names a role's TS files reference through its _ctx: `V.<name>` (only
 * in files that import V from "../_ctx.ts" — a file may instead use the global
 * V from lib/ansible.ts), plus `isDef("<name>")` / `notVar("<name>")` (always
 * _ctx exports).
 */
async function usedNames(roleName: string): Promise<Set<string>> {
  const used = new Set<string>();
  for (const sub of ["tasks", "handlers"]) {
    const dir = new URL(`${roleName}/${sub}/`, tsRoles);
    const entries: Deno.DirEntry[] = [];
    try {
      for await (const f of Deno.readDir(dir)) entries.push(f);
    } catch {
      continue;
    }
    for (const f of entries) {
      if (!f.isFile || !f.name.endsWith(".ts")) continue;
      const src = await Deno.readTextFile(new URL(f.name, dir));
      const ctxImport = src.match(
        /import \{([^}]*)\} from "\.\.\/_ctx\.ts";/s,
      );
      const ctxNames = new Set(
        (ctxImport?.[1] ?? "").split(",").map((s) => s.trim()),
      );
      if (ctxNames.has("V")) {
        for (const m of src.matchAll(/\bV\.([A-Za-z_]\w*)/g)) used.add(m[1]);
      }
      for (
        const m of src.matchAll(/\b(?:isDef|notVar)\(\s*["']([A-Za-z_]\w*)/g)
      ) {
        used.add(m[1]);
      }
    }
  }
  return used;
}

// The helpers context() can provide, in canonical emit order.
const HELPER_ORDER = ["V", "tmpl", "isDef", "notVar"];

/**
 * Which _ctx helpers a role's task/handler files actually import from
 * "../_ctx.ts" (e.g. `V`, `tmpl`, `isDef`). The emitted destructuring exports
 * only these, so an unused helper never lingers in a role's _ctx.
 */
async function usedHelpers(roleName: string): Promise<Set<string>> {
  const used = new Set<string>();
  for (const sub of ["tasks", "handlers"]) {
    const dir = new URL(`${roleName}/${sub}/`, tsRoles);
    const entries: Deno.DirEntry[] = [];
    try {
      for await (const f of Deno.readDir(dir)) entries.push(f);
    } catch {
      continue;
    }
    for (const f of entries) {
      if (!f.isFile || !f.name.endsWith(".ts")) continue;
      const src = await Deno.readTextFile(new URL(f.name, dir));
      const ctxImport = src.match(
        /import \{([^}]*)\} from "\.\.\/_ctx\.ts";/s,
      );
      if (!ctxImport) continue;
      for (const raw of ctxImport[1].split(",")) {
        const name = raw.trim().split(/\s+as\s+/)[0].trim();
        if (name) used.add(name);
      }
    }
  }
  return used;
}

// ---------------------------------------------------------------------------
// Shared vars: the role-defined names referenced from OUTSIDE their owning role
// (a different role's task/handler `V.x`, or a `{{ }}`/`{% %}` ref in another
// role's defaults/vars). Only these cross-role names need a shared registry —
// the other ~95% of role vars are private to their role and covered by its own
// `Vars`. The per-role and data-file context widenings intersect `SharedVars`
// (this small set) instead of the 644-name `AllVars`, the first step toward an
// explicit role-to-role dependency graph.
// ---------------------------------------------------------------------------
const ownerOf = new Map<string, Set<string>>(); // var name -> defining roles
for (const [role, vs] of roleVars) {
  for (const name of vs.keys()) {
    (ownerOf.get(name) ?? ownerOf.set(name, new Set()).get(name)!).add(role);
  }
}
// A name typed by another registry isn't "shared role state" — it resolves
// through that registry's widening, not SharedVars.
const inOtherRegistry = (n: string) =>
  GLOBALS.has(n) || BUILTINS.has(n) || PARAMVARS.has(n) || VAULTVARS.has(n) ||
  SHAPES.has(n);
const sharedVars = new Set<string>();
// `byRole` null = an external file (inventory, group_vars, playbook): any
// role var it names is cross-role by definition.
const markIfCrossRole = (name: string, byRole: string | null) => {
  const owners = ownerOf.get(name);
  if (owners && (byRole === null || !owners.has(byRole)) && !inOtherRegistry(name)) {
    sharedVars.add(name);
  }
};
// Cross-role references in task/handler TS (`V.x` / isDef / notVar).
for (const roleName of roleVars.keys()) {
  for (const name of await usedNames(roleName)) markIfCrossRole(name, roleName);
}
// Cross-role references in every devops YAML value (`{{ x }}` / `{% … %}`): a
// role's own files attribute to that role; everything else is external.
const devops = new URL("../devops/", import.meta.url);
async function scanYamlRefs(dir: URL, role: string | null) {
  const entries: Deno.DirEntry[] = [];
  try {
    for await (const f of Deno.readDir(dir)) entries.push(f);
  } catch {
    return;
  }
  for (const f of entries) {
    const child = new URL(`${f.name}/`, dir);
    if (f.isDirectory) {
      // Directly under devops/roles/, each subdir is a role; else inherit.
      const scope = dir.pathname.endsWith("/roles/") ? f.name : role;
      await scanYamlRefs(child, scope);
    } else if (f.isFile && f.name.endsWith(".yml")) {
      const raw = await Deno.readTextFile(new URL(f.name, dir));
      for (const blk of raw.matchAll(/\{\{(.*?)\}\}|\{%(.*?)%\}/gs)) {
        for (const id of (blk[1] ?? blk[2] ?? "").matchAll(/[A-Za-z_]\w*/g)) {
          markIfCrossRole(id[0], role);
        }
      }
    }
  }
}
await scanYamlRefs(devops, null);

// Emit the shared-vars registry (the cross-role surface).
const sharedLines = [...sharedVars]
  .sort((a, b) => a.localeCompare(b))
  .map((n) => `  ${ident.test(n) ? n : JSON.stringify(n)}: unknown;`);
const sharedOut =
  `// Auto-generated by gen-contexts.ts.\n` +
  `// Role-defined variables that are referenced from OUTSIDE their defining\n` +
  `// role (the cross-role surface). The per-role and data-file context\n` +
  `// widenings intersect this — not every role var — so a file declares\n` +
  `// only the shared state it touches. \`unknown\` (names matter, not types).\n` +
  (sharedLines.length
    ? `export interface SharedVars {\n${sharedLines.join("\n")}\n}\n`
    : `// deno-lint-ignore no-empty-interface\nexport interface SharedVars {}\n`);
await Deno.writeTextFile(
  new URL("./lib/sharedvars.ts", import.meta.url),
  sharedOut,
);

let generated = 0;
for (const [roleName, vars] of roleVars) {
  // Ensure the role's TS dir exists (it does for ported roles; create otherwise).
  const outDir = new URL(`${roleName}/`, tsRoles);
  try {
    await Deno.mkdir(outDir, { recursive: true });
  } catch { /* exists */ }

  // Pick, per used name, the registry that provides it. A shaped name needs
  // VarShapes (its object type lives there; everywhere else it is `unknown`);
  // otherwise prefer the most specific source, falling back to the cross-role
  // SharedVars. Unmatched names (e.g. `V.x` in a comment) are ignored — if real,
  // the type check fails and points at them.
  const used = await usedNames(roleName);
  const helpers = await usedHelpers(roleName);
  const needs = {
    Vars: false,
    Globals: false,
    BuiltinVars: false,
    SharedVars: false,
    ParamVars: false,
    VaultVars: false,
    VarShapes: false,
  };
  for (const name of used) {
    if (SHAPES.has(name)) needs.VarShapes = true;
    else if (vars.has(name)) needs.Vars = true;
    else if (GLOBALS.has(name)) needs.Globals = true;
    else if (BUILTINS.has(name)) needs.BuiltinVars = true;
    else if (PARAMVARS.has(name)) needs.ParamVars = true;
    else if (VAULTVARS.has(name)) needs.VaultVars = true;
    else if (sharedVars.has(name)) needs.SharedVars = true;
  }
  needs.Vars ||= used.size === 0; // floor: context<Vars> (possibly empty)

  const lines = [...vars.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([name, type]) => {
      const key = ident.test(name) ? name : JSON.stringify(name);
      return `  ${key}: ${type};`;
    });

  const body = lines.length
    ? `export interface Vars {\n${lines.join("\n")}\n}`
    : `// deno-lint-ignore no-empty-interface\nexport interface Vars {}`;

  // The inferred Vars types may reference `Tmpl`/`VarValue` (from lib/ansible);
  // import whichever the interface actually uses, independent of the context
  // helpers (a role with no context() still has a typed Vars its data satisfies).
  const allTypes = [...vars.values()].join(" ");
  const libTypes = ["Tmpl", "VarValue"]
    .filter((t) => new RegExp(`\\b${t}\\b`).test(allTypes));
  const typeImports = libTypes.length
    ? `import type { ${libTypes.join(", ")} } from "../../lib/ansible.ts";\n`
    : "";

  // Export only the helpers the role's task/handler files actually import. A
  // role that imports none needs no context() call at all, so emit just the
  // Vars interface (and drop the otherwise-unused `context`/registry imports).
  const emitted = HELPER_ORDER.filter((h) => helpers.has(h));

  const imports = emitted.length === 0 ? "" : [
    `import { context } from "../../lib/context.ts";\n`,
    needs.Globals
      ? `import type { Globals } from "../../lib/globals.ts";\n`
      : "",
    needs.BuiltinVars
      ? `import type { BuiltinVars } from "../../lib/builtins.ts";\n`
      : "",
    needs.SharedVars
      ? `import type { SharedVars } from "../../lib/sharedvars.ts";\n`
      : "",
    needs.ParamVars
      ? `import type { ParamVars } from "../../lib/paramvars.ts";\n`
      : "",
    needs.VaultVars
      ? `import type { VaultVars } from "../../lib/vaultvars.ts";\n`
      : "",
    needs.VarShapes
      ? `import type { VarShapes } from "../../lib/shapes.ts";\n`
      : "",
  ].join("");

  const widening = (Object.keys(needs) as Array<keyof typeof needs>)
    .filter((k) => needs[k])
    .join(" & ");

  const contextDecl = emitted.length === 0 ? "" : `\nexport const { ${
    emitted.join(", ")
  } } = context<\n  ${widening}\n>();\n`;

  const out = `// Auto-generated by gen-contexts.ts from\n` +
    `// ../../../devops/roles/${roleName}/{defaults,vars}/*.yml\n` +
    `// Per-role variable context: ${vars.size} own variables, widened with\n` +
    `// only the registries this role's task/handler files reference.\n` +
    typeImports +
    imports +
    `\n${body}\n` +
    contextDecl;

  await Deno.writeTextFile(new URL("_ctx.ts", outDir), out);
  generated++;
}

// Emit the per-role parameter-coverage check (replaces the old flat AllVars +
// the paramvars.ts global check). Every parameter a role declares in
// lib/roles.ts must be reachable as `V.x` from that role — covered by the
// role's OWN `Vars` (its _ctx) or a shared registry. A compile error names the
// role + parameter with no home.
const covImports: string[] = [];
const covChecks: string[] = [];
for (const roleName of [...roleVars.keys()].sort()) {
  const alias = "V_" + roleName.replace(/[^A-Za-z0-9]/g, "_");
  covImports.push(
    `import type { Vars as ${alias} } from "../roles/${roleName}/_ctx.ts";`,
  );
  covChecks.push(`export type _cov_${alias} = Assert<Missing<"${roleName}", ${alias}>>;`);
}
const covOut =
  `// Auto-generated by gen-contexts.ts.\n` +
  `// Per-role parameter-coverage check: every parameter a role declares in\n` +
  `// lib/roles.ts must be reachable as \`V.x\` from that role — covered by the\n` +
  `// role's own \`Vars\` (its _ctx) or a shared registry. A compile error on a\n` +
  `// \`_cov_*\` names a role whose parameter has no home: add it to\n` +
  `// lib/paramvars.ts (or give the role a default for it).\n` +
  `import type { Roles } from "./roles.ts";\n` +
  `import type { ParamVars } from "./paramvars.ts";\n` +
  `import type { Globals } from "./globals.ts";\n` +
  `import type { BuiltinVars } from "./builtins.ts";\n` +
  `import type { SharedVars } from "./sharedvars.ts";\n` +
  `import type { VaultVars } from "./vaultvars.ts";\n` +
  `import type { VarShapes } from "./shapes.ts";\n` +
  covImports.join("\n") +
  `\n\n` +
  `type Reg =\n  | keyof ParamVars\n  | keyof Globals\n  | keyof BuiltinVars\n` +
  `  | keyof SharedVars\n  | keyof VaultVars\n  | keyof VarShapes;\n` +
  `// Parameters a role's roles.ts schema declares (minus the envelope keys);\n` +
  `// a schema with an index signature (string keys) declares none to check.\n` +
  `type Params<R extends string> = R extends keyof Roles\n` +
  `  ? (string extends keyof Roles[R] ? never\n` +
  `    : Exclude<keyof Roles[R] & string, "name" | "vars">)\n  : never;\n` +
  `type Missing<R extends string, Own> = Exclude<Params<R>, keyof Own | Reg>;\n` +
  `type Assert<T extends never> = T;\n` +
  covChecks.join("\n") + `\n`;
await Deno.writeTextFile(
  new URL("./lib/role-coverage.ts", import.meta.url),
  covOut,
);

console.log(
  `Generated ${generated} role contexts; ${sharedVars.size} shared vars.`,
);
