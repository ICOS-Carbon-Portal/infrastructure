// Generate typed TS modules for the non-executable data files, mirroring the
// devops layout under data/:
//   roles/<r>/meta/*.yml      -> data/roles/<r>/meta/*.ts        (Meta)
//   roles/<r>/{defaults,vars} -> data/roles/<r>/{defaults,vars}  (VarsFile)
//   *.inventory/**            -> data/*.inventory/**             (Inventory)
//   host_vars,group_vars/**   -> data/{host_vars,group_vars}/**  (VarsFile)
//
// Each module is `export default <data literal> satisfies <Type>`, rendering
// back to semantically-identical YAML (verified by verify.ts).
//
// Encrypted Ansible-vault files ($ANSIBLE_VAULT) and files with inline !vault
// tags are skipped — they are ciphertext, not data, and must stay as .yml.
//
//   deno run --allow-read --allow-write --allow-env gen-data.ts
import { parse } from "yaml";
import { isBareIdent, parseJinja } from "./lib/jinja-parse.ts";

const bt = (s: string) =>
  s.replace(/\\/g, "\\\\").replace(/`/g, "\\`").replace(/\$\{/g, "\\${");

const devops = new URL("../devops/", import.meta.url);
const dataOut = new URL("./data/", import.meta.url);

// Variable names a data file can reference without declaring them itself:
// globals (group_vars/inventory) + Ansible built-ins. A reference to one of
// these, or to the file's own top-level key, becomes a checked `V.x`.
const ifaceNames = (path: string) =>
  new Set(
    [
      ...Deno.readTextFileSync(new URL(path, import.meta.url))
        .matchAll(/^\s{2}([A-Za-z_$][\w$]*)\??:/gm),
    ].map((m) => m[1]),
  );
const GLOBALS = ifaceNames("./lib/globals.ts");
const BUILTINS = ifaceNames("./lib/builtins.ts");
// Role-defined variable names (system-wide flat namespace; see lib/allvars.ts).
// A data file referencing one becomes a checked `V.x`, not an `expr("x")`.
const ALLVARS = ifaceNames("./lib/allvars.ts");
// Role caller-params / play vars and vault-defined names (hand-curated
// registries; see lib/paramvars.ts and lib/vaultvars.ts).
const PARAMVARS = ifaceNames("./lib/paramvars.ts");
const VAULTVARS = ifaceNames("./lib/vaultvars.ts");
const SHAPES = ifaceNames("./lib/shapes.ts");
// The filter methods modelled on Template (lib/template.ts) — a canonical
// `x | default(False) | bool` chain over a known name converts to checked
// method calls instead of an expr() escape.
const SIMPLE_FILTERS = new Set([
  "bool",
  "int",
  "lower",
  "first",
  "dirname",
  "basename",
  "splitext",
  "b64decode",
]);
// Object-shaped variables (lib/shapes.ts + hand-declared facts) whose dotted
// paths are checked: name -> allowed paths.
const SHAPED = new Map<string, Set<string>>([
  ["ansible_lsb", new Set(["id", "codename", "release", "major_release"])],
  ["ansible_default_ipv4", new Set(["gateway"])],
  ["ansible_python", new Set(["version.major", "version.minor"])],
  [
    "wg_hub_config",
    new Set([
      "name",
      "allow_all",
      "allowed_ips",
      "reresolve",
      "peers",
      "hub.addr",
      "hub.peer",
      "hub.port",
    ]),
  ],
  ["wg_hub_self", new Set(["addr", "port"])],
  ["jbuild_registry", new Set(["url", "username", "password"])],
  ["city_restheart_basic_auth", new Set(["username", "password"])],
  ["user_conf", new Set(["create_users", "remove_users"])],
  ["vmagent_auth", new Set(["username", "password"])],
  ["vault_vmagent_auth", new Set(["username", "password"])],
]);

// Names registered by tasks (`register: foo`) across the playbooks. A data
// default that references a registered result (`{{ _release.tag }}`) is a
// cross-file reference the registries can't cover, so it would otherwise stay
// an expr() escape; recognizing the name lets gen-data emit a typed
// `register("_release").tag.ref` handle instead. The rendered Jinja is
// identical, and register()'s proxy accepts any field, so this is byte-safe.
function collectRegisterNames(dir: URL): Set<string> {
  const out = new Set<string>();
  for (const e of Deno.readDirSync(dir)) {
    if (e.isDirectory) {
      for (const n of collectRegisterNames(new URL(`${e.name}/`, dir))) {
        out.add(n);
      }
    } else if (e.name.endsWith(".yml") || e.name.endsWith(".yaml")) {
      const txt = Deno.readTextFileSync(new URL(e.name, dir));
      for (
        const m of txt.matchAll(/^\s*register:\s*["']?([A-Za-z_]\w*)["']?/gm)
      ) {
        out.add(m[1]);
      }
    }
  }
  return out;
}
const REGISTERS = collectRegisterNames(devops);
// Template methods reachable on a register field's `.ref` (lib/template.ts).
const REG_METHODS = new Set(["lstrip", "rstrip"]);

/**
 * A checked register-result expression for a Jinja head whose root is a known
 * register, or null. Handles `reg.a.b`, a `[int]` index, and a trailing
 * modelled method (`.lstrip('v')`): `_unar.files[0].rstrip('/')` ->
 * `register("_unar").files.ref.at(0).rstrip("/")`.
 */
function registerExpr(head: string): string | null {
  const root = head.match(/^[A-Za-z_]\w*/)?.[0];
  if (!root || !REGISTERS.has(root)) return null;
  let rest = head.slice(root.length);
  let out = `register(${JSON.stringify(root)})`;
  let m: RegExpMatchArray | null;
  // Field navigation on the register proxy: a complete `.ident` not opening a
  // call. The `[\w(]` lookahead (not just `(`) stops greedy `\w*` from
  // backtracking to a partial ident before a method call (`.lstrip(` -> `.lstri`).
  while ((m = rest.match(/^\.([A-Za-z_]\w*)(?![\w(])/))) {
    out += `.${m[1]}`;
    rest = rest.slice(m[0].length);
  }
  out += ".ref";
  // Value-position ops on the resulting Template: `[int]` and modelled methods.
  while (rest) {
    if ((m = rest.match(/^\[(\d+)\]/))) {
      out += `.at(${m[1]})`;
    } else if ((m = rest.match(/^\.([A-Za-z_]\w*)\('([^']*)'\)/))) {
      if (!REG_METHODS.has(m[1])) return null;
      out += `.${m[1]}(${JSON.stringify(m[2])})`;
    } else {
      return null;
    }
    rest = rest.slice(m[0].length);
  }
  return out;
}

/** Pick the `satisfies` type + its export name for a given relative path. */
function typeFor(rel: string): { name: string } {
  if (/\/meta\//.test(rel)) return { name: "Meta" };
  if (/\.inventory\//.test(rel)) return { name: "Inventory" };
  return { name: "VarsFile" }; // defaults, vars, host_vars, group_vars
}

/** Collect every candidate data .yml under devops. */
async function dataYmls(): Promise<string[]> {
  const out: string[] = [];
  async function walk(dir: URL, rel: string) {
    for await (const e of Deno.readDir(dir)) {
      const childRel = rel ? `${rel}/${e.name}` : e.name;
      if (e.isDirectory) {
        await walk(new URL(`${e.name}/`, dir), childRel);
      } else if (e.isFile && e.name.endsWith(".yml")) {
        out.push(childRel);
      }
    }
  }
  // roles/<r>/{meta,defaults,vars}
  for await (const role of Deno.readDir(new URL("roles/", devops))) {
    if (!role.isDirectory) continue;
    for (const sub of ["meta", "defaults", "vars"]) {
      await walk(
        new URL(`roles/${role.name}/${sub}/`, devops),
        `roles/${role.name}/${sub}`,
      ).catch(() => {});
    }
  }
  // *.inventory/**, host_vars/**, group_vars/**, fixes/vars/** (vars_files data)
  for await (const e of Deno.readDir(devops)) {
    if (!e.isDirectory) continue;
    if (
      e.name.endsWith(".inventory") || e.name === "host_vars" ||
      e.name === "group_vars"
    ) {
      await walk(new URL(`${e.name}/`, devops), e.name);
    }
  }
  await walk(new URL("fixes/vars/", devops), "fixes/vars").catch(() => {});
  return out;
}

let generated = 0;
const skipped: string[] = [];

for (const rel of await dataYmls()) {
  const raw = await Deno.readTextFile(new URL(rel, devops));
  if (raw.includes("$ANSIBLE_VAULT")) {
    skipped.push(`${rel} (encrypted vault)`);
    continue;
  }
  if (/!vault|!unsafe/.test(raw)) {
    skipped.push(`${rel} (inline !vault tag)`);
    continue;
  }
  let doc: unknown;
  try {
    // Parse as YAML 1.1 (like Ansible's PyYAML and verify.ts), so `yes`/`no`
    // become booleans rather than the strings "yes"/"no".
    doc = parse(raw, { version: "1.1" });
  } catch (e) {
    skipped.push(`${rel} (parse error: ${e instanceof Error ? e.message : e})`);
    continue;
  }
  if (doc === null || doc === undefined) {
    skipped.push(`${rel} (empty)`);
    continue;
  }

  const { name } = typeFor(rel);
  const ups = "../".repeat(rel.split("/").length); // dir depth + 1 (for data/)
  const used = new Set<string>();

  // A VarsFile (defaults/vars/host_vars/group_vars) may reference its own
  // top-level keys; inventory/meta files reference only globals/builtins.
  const ownKeys = name === "VarsFile" && doc && typeof doc === "object" &&
      !Array.isArray(doc)
    ? Object.keys(doc as Record<string, unknown>).filter(isBareIdent)
    : [];
  const known = new Set([
    ...ownKeys,
    ...GLOBALS,
    ...BUILTINS,
    ...ALLVARS,
    ...PARAMVARS,
    ...VAULTVARS,
    ...SHAPES,
  ]);
  // Self excludes names already in Globals/BuiltinVars (avoid intersection
  // collapsing to `never`); they remain reachable via the widening.
  const selfKeys = ownKeys.filter((k) => !GLOBALS.has(k) && !BUILTINS.has(k));

  /**
   * A checked TS expression for a canonical Jinja value expression, or null:
   * a known bare name (`V.x`), a known-shape dotted path (`V.a.b`), a
   * `name[key]` index of known names (`V.a.at(V.b)`), and/or a chain of the
   * modelled filters (`V.x.default(false).bool()`). Anything else stays expr().
   */
  function checkedRef(inner: string): string | null {
    const segs = inner.split(" | ");
    let head = segs[0];
    let out: string | null = null;
    if (isBareIdent(head) && known.has(head)) out = `V.${head}`;
    else if (/^hostvars[.[]/.test(head)) {
      // hostvars.localhost.x / hostvars[known_var].x -> checked hostvar()
      const lit = head.match(/^hostvars\.([A-Za-z_]\w*)\.([A-Za-z_]\w*)$/);
      const dyn = head.match(/^hostvars\[([A-Za-z_]\w*)\]\.([A-Za-z_]\w*)$/);
      if (lit && known.has(lit[2])) {
        used.add("hostvar");
        out = `hostvar(${JSON.stringify(lit[1])}).${lit[2]}`;
      } else if (dyn && known.has(dyn[1]) && known.has(dyn[2])) {
        used.add("hostvar");
        used.add("V");
        out = `hostvar(V.${dyn[1]}).${dyn[2]}`;
      }
    } else {
      const idx = head.match(/^([A-Za-z_]\w*)\[([A-Za-z_]\w*)\]$/);
      if (idx && known.has(idx[1]) && known.has(idx[2])) {
        out = `V.${idx[1]}.at(V.${idx[2]})`;
      } else {
        const dot = head.match(
          /^([A-Za-z_]\w*)((?:\.[A-Za-z_]\w*)+)(?:\[([A-Za-z_]\w*)\])?$/,
        );
        if (dot && SHAPED.get(dot[1])?.has(dot[2].slice(1))) {
          if (dot[3] === undefined) out = `V.${dot[1]}${dot[2]}`;
          else if (known.has(dot[3])) {
            out = `V.${dot[1]}${dot[2]}.at(V.${dot[3]})`;
          }
        }
      }
    }
    if (!out) {
      const r = registerExpr(head);
      if (r) {
        used.add("register");
        out = r;
      }
    }
    if (!out) return null;
    for (const f of segs.slice(1)) {
      if (SIMPLE_FILTERS.has(f)) {
        out += `.${f}()`;
        continue;
      }
      const m = f.match(/^(default|combine)\((.*)\)$/);
      if (!m) return null;
      const arg = filterArg(m[2]);
      if (arg === null) return null;
      out += `.${m[1]}(${arg})`;
    }
    return out;
  }
  function filterArg(a: string): string | null {
    if (a === "omit") return "V.omit";
    if (a === "False") return "false";
    if (a === "True") return "true";
    if (a === "[]") return "[]";
    if (/^-?\d+$/.test(a)) return a;
    const s = a.match(/^'([^'\\]*)'$/);
    if (s) return JSON.stringify(s[1]);
    if (isBareIdent(a) && known.has(a)) return `V.${a}`;
    return null;
  }

  /** A value operand: integer, `'…'`/`"…"` literal, or a known bare ref. */
  function valueArg(a: string): string | null {
    a = a.trim();
    if (/^-?\d+$/.test(a)) return a;
    const sq = a.match(/^'([^'\\]*)'$/);
    if (sq) return JSON.stringify(sq[1]);
    const dq = a.match(/^"([^"\\]*)"$/);
    if (dq) return JSON.stringify(dq[1]);
    if (isBareIdent(a) && known.has(a)) return `V.${a}`;
    return null;
  }
  /** A ternary condition: `x`, `x == lit`, or `lit in x`. */
  function condExpr(c: string): string | null {
    c = c.trim();
    let m = c.match(/^([A-Za-z_]\w*) == (.+)$/);
    if (m && isBareIdent(m[1]) && known.has(m[1])) {
      const rhs = valueArg(m[2]);
      if (rhs !== null) {
        used.add("eq");
        return `eq(V.${m[1]}, ${rhs})`;
      }
    }
    m = c.match(/^(.+?) in ([A-Za-z_]\w*)$/);
    if (m && isBareIdent(m[2]) && known.has(m[2])) {
      const lhs = valueArg(m[1]);
      if (lhs !== null) {
        used.add("isIn");
        return `isIn(${lhs}, V.${m[2]})`;
      }
    }
    if (isBareIdent(c) && known.has(c)) return `V.${c}`;
    return null;
  }
  /**
   * A modelled value expression for the cleanly-reducible Jinja the checked-ref
   * path doesn't cover: `lookup(...)`, `a + b`, `N | random(seed=x)`, and simple
   * `A if C else B` ternaries. Returns the TS source, or null (-> rawTmpl). Any
   * unresolved operand yields null, so nothing is emitted that could drift.
   */
  function modelledValue(inner: string): string | null {
    const lk = inner.match(/^lookup\((.+)\)$/);
    if (lk && !/[()]/.test(lk[1])) {
      const args = lk[1].split(",").map(valueArg);
      if (args.length && args.every((a) => a !== null)) {
        used.add("lookup");
        return `lookup(${args.join(", ")})`;
      }
    }
    const rnd = inner.match(/^(\d+) \| random\(seed=(.+)\)$/);
    if (rnd) {
      const seed = valueArg(rnd[2]);
      if (seed !== null) {
        used.add("randomInt");
        return `randomInt(${rnd[1]}, ${seed})`;
      }
    }
    if (/^[A-Za-z_]\w*( \+ [A-Za-z_]\w*)+$/.test(inner)) {
      const parts = inner.split(" + ");
      if (parts.every((p) => known.has(p))) {
        used.add("concat");
        return `concat(${parts.map((p) => `V.${p}`).join(", ")})`;
      }
    }
    const tern = inner.match(/^(.+?) if (.+?) else (.+)$/);
    if (tern) {
      const then = valueArg(tern[1]);
      const cond = condExpr(tern[2]);
      const els = valueArg(tern[3]);
      if (then !== null && cond !== null && els !== null) {
        used.add("iff");
        return `iff(${cond}, ${then}, ${els})`;
      }
    }
    return null;
  }

  const literal = emit(doc, "");

  // Header. When V is used, source the template helpers from a per-file context
  // (so there's a single `V`/`expr`/`tmpl`/`rawTmpl`); otherwise import the few
  // helpers used directly from lib/ansible.ts.
  let header = `// Auto-generated by gen-data.ts from ../devops/${rel}\n` +
    `import type { ${name} } from "${ups}lib/data.ts";\n`;
  if (used.has("register")) {
    header += `import { register } from "${ups}lib/ansible.ts";\n`;
    used.delete("register");
  }
  if (used.has("V")) {
    // Value-builder primitives live in lib/ansible.ts, not the per-file
    // context() (which provides only V/tmpl/rawTmpl). Import any that are used.
    const ANSIBLE = ["concat", "eq", "hostvar", "iff", "isIn", "lookup", "randomInt"];
    const fromAnsible = ANSIBLE.filter((h) => used.has(h));
    if (fromAnsible.length) {
      header += `import { ${fromAnsible.join(", ")} } from "${ups}lib/ansible.ts";\n`;
      for (const h of fromAnsible) used.delete(h);
    }
    const helpers = [
      "V",
      ...["tmpl", "rawTmpl"].filter((h) => used.has(h)),
    ];
    // Widen the context with ONLY the registries that cover the names this
    // file actually references through V (scanned from the emitted literal),
    // so each data module carries the smallest type that still checks.
    const usedNames = new Set(
      [...literal.matchAll(/\bV\.([A-Za-z_]\w*)/g)].map((m) => m[1]),
    );
    const selfSet = new Set(selfKeys);
    const needs = {
      Self: false,
      Globals: false,
      BuiltinVars: false,
      AllVars: false,
      ParamVars: false,
      VaultVars: false,
      VarShapes: false,
    };
    for (const n of usedNames) {
      if (SHAPES.has(n)) needs.VarShapes = true;
      else if (selfSet.has(n)) needs.Self = true;
      else if (GLOBALS.has(n)) needs.Globals = true;
      else if (BUILTINS.has(n)) needs.BuiltinVars = true;
      else if (PARAMVARS.has(n)) needs.ParamVars = true;
      else if (VAULTVARS.has(n)) needs.VaultVars = true;
      else if (ALLVARS.has(n)) needs.AllVars = true;
    }
    needs.Self ||= usedNames.size === 0; // floor: context<Self>
    const self = needs.Self
      ? (selfKeys.length
        ? `interface Self {\n${
          selfKeys.map((k) => `  ${k}: unknown;`).join("\n")
        }\n}\n`
        : `type Self = Record<never, never>;\n`)
      : "";
    const widening = (Object.keys(needs) as Array<keyof typeof needs>)
      .filter((k) => needs[k])
      .join(" & ");
    header += `import { context } from "${ups}lib/context.ts";\n` +
      (needs.Globals
        ? `import type { Globals } from "${ups}lib/globals.ts";\n`
        : "") +
      (needs.BuiltinVars
        ? `import type { BuiltinVars } from "${ups}lib/builtins.ts";\n`
        : "") +
      (needs.AllVars
        ? `import type { AllVars } from "${ups}lib/allvars.ts";\n`
        : "") +
      (needs.ParamVars
        ? `import type { ParamVars } from "${ups}lib/paramvars.ts";\n`
        : "") +
      (needs.VaultVars
        ? `import type { VaultVars } from "${ups}lib/vaultvars.ts";\n`
        : "") +
      (needs.VarShapes
        ? `import type { VarShapes } from "${ups}lib/shapes.ts";\n`
        : "") +
      `\n` +
      self +
      `const { ${helpers.join(", ")} } = context<${widening}>();\n`;
  } else if (used.size) {
    header += `import { ${
      [...used].sort().join(", ")
    } } from "${ups}lib/ansible.ts";\n`;
  }
  const out = `${header}\nexport default ${literal} satisfies ${name};\n`;

  /** A templated string -> structured V/expr/tmpl/rawTmpl. */
  function strTemplate(v: string): string {
    // Annotate the callback's return type: without it, inference normalizes the
    // union to `{ lit; interp?: undefined } | { interp; lit?: undefined }` (so
    // the filter can read `p.lit` on both arms), and that shared `interp` key
    // defeats the `"interp" in pieces[0]` discriminant below.
    type Piece = { lit: string } | { interp: string };
    const pieces = parseJinja(v).map((seg): Piece => {
      if (seg.kind === "lit") return { lit: bt(seg.text) };
      if (seg.canonical && seg.delim === "{{") {
        const checked = checkedRef(seg.inner);
        if (checked) {
          if (/\bV\./.test(checked)) used.add("V");
          return { interp: checked };
        }
        const modelled = modelledValue(seg.inner);
        if (modelled) {
          if (/\bV\./.test(modelled)) used.add("V");
          return { interp: modelled };
        }
      }
      // Anything not a checked ref or a modelled value expression renders
      // verbatim. A canonical `{{ <inner> }}` segment's `raw` is exactly what
      // `expr(<inner>)` would have produced, so this stays byte-identical.
      used.add("rawTmpl");
      return { interp: `rawTmpl(${JSON.stringify(seg.raw)})` };
    }).filter((p) => "interp" in p || p.lit !== "");
    if (pieces.length === 1 && "interp" in pieces[0]) return pieces[0].interp;
    used.add("tmpl");
    return "tmpl`" +
      pieces.map((p) => "lit" in p ? p.lit : `\${${p.interp}}`).join("") + "`";
  }

  // Serialize like JSON, but emit Jinja-template strings as structured templates
  // so they render as quoted scalars (matching the role/playbook quoting).
  function emit(v: unknown, indent: string): string {
    if (typeof v === "string") {
      return (v.includes("{{") || v.includes("{%"))
        ? strTemplate(v)
        : JSON.stringify(v);
    }
    if (v === null || typeof v === "number" || typeof v === "boolean") {
      return JSON.stringify(v);
    }
    const inner = `${indent}  `;
    if (Array.isArray(v)) {
      if (v.length === 0) return "[]";
      const items = v.map((x) => `${inner}${emit(x, inner)}`).join(",\n");
      return `[\n${items}\n${indent}]`;
    }
    const entries = Object.entries(v as Record<string, unknown>);
    if (entries.length === 0) return "{}";
    const items = entries
      .map(([k, val]) => `${inner}${JSON.stringify(k)}: ${emit(val, inner)}`)
      .join(",\n");
    return `{\n${items}\n${indent}}`;
  }

  const outUrl = new URL(rel.replace(/\.yml$/, ".ts"), dataOut);
  await Deno.mkdir(new URL(".", outUrl), { recursive: true });
  await Deno.writeTextFile(outUrl, out);
  generated++;
}

console.log(`Generated ${generated} data modules; skipped ${skipped.length}:`);
for (const s of skipped) console.log(`  - ${s}`);
