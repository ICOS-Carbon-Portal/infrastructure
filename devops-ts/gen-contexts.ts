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

// Every var name is declared `unknown`: only the NAMES matter (the V accessor
// maps a scalar-typed key to a plain Ref). `unknown` (not `string`) keeps the
// `Vars & ... & AllVars & VarShapes` intersection conflict-free — `unknown & T
// = T`, so a hand-declared type (a fact shape in lib/shapes.ts, a boolean
// global) wins instead of intersecting to a `never`-valued property.
function tsType(_v: unknown): string {
  return "unknown";
}

/** A valid bare TS identifier needs no quoting as an interface key. */
const ident = /^[A-Za-z_$][A-Za-z0-9_$]*$/;

// ---------------------------------------------------------------------------
// Pass 1: collect every role's own variable names (defaults/vars yml). The
// full cross-role set is needed before emitting any context (a role may
// reference another role's var through AllVars).
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
        doc = parse(await Deno.readTextFile(new URL(f.name, dir)));
      } catch {
        continue;
      }
      if (doc && typeof doc === "object" && !Array.isArray(doc)) {
        for (const [k, v] of Object.entries(doc as Record<string, unknown>)) {
          if (reserved.has(k)) continue; // covered by Globals/BuiltinVars widening
          if (!vars.has(k) || vars.get(k) === "unknown") {
            vars.set(k, tsType(v));
          }
        }
      }
    }
  }
  roleVars.set(role.name, vars);
}

// Every var name defined in ANY role's defaults/vars (see lib/allvars.ts).
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
const HELPER_ORDER = ["V", "tmpl", "expr", "rawTmpl", "isDef", "notVar"];

/**
 * Which _ctx helpers a role's task/handler files actually import from
 * "../_ctx.ts" (e.g. `V`, `tmpl`, `expr`). The emitted destructuring exports
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

let generated = 0;
for (const [roleName, vars] of roleVars) {
  // Ensure the role's TS dir exists (it does for ported roles; create otherwise).
  const outDir = new URL(`${roleName}/`, tsRoles);
  try {
    await Deno.mkdir(outDir, { recursive: true });
  } catch { /* exists */ }

  // Pick, per used name, the registry that provides it. A shaped name needs
  // VarShapes (its object type lives there; everywhere else it is `unknown`);
  // otherwise prefer the most specific source, falling back to the system-wide
  // AllVars. Unmatched names (e.g. `V.x` in a comment) are ignored — if real,
  // the type check fails and points at them.
  const used = await usedNames(roleName);
  const helpers = await usedHelpers(roleName);
  const needs = {
    Vars: false,
    Globals: false,
    BuiltinVars: false,
    AllVars: false,
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
    else if (allVars.has(name)) needs.AllVars = true;
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
    needs.AllVars
      ? `import type { AllVars } from "../../lib/allvars.ts";\n`
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
    imports +
    `\n${body}\n` +
    contextDecl;

  await Deno.writeTextFile(new URL("_ctx.ts", outDir), out);
  generated++;
}

// Emit the flat, system-wide registry of role-defined variable names.
const allVarLines = [...allVars]
  .sort((a, b) => a.localeCompare(b))
  .map((name) =>
    `  ${ident.test(name) ? name : JSON.stringify(name)}: unknown;`
  );
const allVarsOut =
  `// Auto-generated by gen-contexts.ts from ../../../devops/roles/*/{defaults,vars}/*.yml\n` +
  `// Flat registry of every variable name defined in ANY role (excluding names\n` +
  `// already in Globals/BuiltinVars). Ansible variable names form a single\n` +
  `// namespace, so a role-defined var is the same variable everywhere; declaring\n` +
  `// the names here lets an inventory or a different role reference one as a\n` +
  `// checked \`V.x\` instead of the \`expr("x")\` escape hatch. Declared as\n` +
  `// \`unknown\` so a hand-declared type elsewhere wins in intersections —\n` +
  `// only the names matter (the V accessor maps every key to a Ref).\n` +
  `export interface AllVars {\n${allVarLines.join("\n")}\n}\n`;
await Deno.writeTextFile(
  new URL("./lib/allvars.ts", import.meta.url),
  allVarsOut,
);

console.log(
  `Generated ${generated} role contexts; ${allVars.size} names in allvars.ts.`,
);
