// Generate the named variable bindings for each names-only registry module.
//
// Each registry (lib/globals.ts, builtins.ts, paramvars.ts, vaultvars.ts)
// declares an interface of variable NAMES (some typed as object shapes whose
// fields a template navigates). This emits, into a trailing auto-generated
// region of each file, one `export const <name>` bound to a `VarRef` so files
// reference Ansible variables the normal TS way —
// `import { ansible_architecture } from "../../lib/builtins.ts"` — instead of a
// `V` proxy. The binding renders `{{ <name> }}` in value position and bare in a
// `when:` subject, exactly as the old `V.<name>` did.
//
// sharedvars.ts gets its bindings from gen-contexts.ts (which writes it whole);
// lib/vars.ts is hand-maintained. Run after gen-contexts.ts.
//
//   deno run --allow-read --allow-write gen-bindings.ts
const MODS: Array<{ file: string; iface: string }> = [
  { file: "globals.ts", iface: "Globals" },
  { file: "builtins.ts", iface: "BuiltinVars" },
  { file: "paramvars.ts", iface: "ParamVars" },
  { file: "vaultvars.ts", iface: "VaultVars" },
];

const SENTINEL =
  "// === auto-generated variable bindings (gen-bindings.ts); do not edit below ===";

const ident = /^[A-Za-z_$][A-Za-z0-9_$]*$/;
// Words that cannot be a `const` binding name.
const RESERVED = new Set([
  "break",
  "case",
  "catch",
  "class",
  "const",
  "continue",
  "debugger",
  "default",
  "delete",
  "do",
  "else",
  "enum",
  "export",
  "extends",
  "false",
  "finally",
  "for",
  "function",
  "if",
  "import",
  "in",
  "instanceof",
  "new",
  "null",
  "return",
  "super",
  "switch",
  "this",
  "throw",
  "true",
  "try",
  "typeof",
  "var",
  "void",
  "while",
  "with",
  "yield",
  "await",
  "let",
]);

for (const { file, iface } of MODS) {
  const url = new URL(`./lib/${file}`, import.meta.url);
  const src = await Deno.readTextFile(url);
  const idx = src.indexOf(SENTINEL);
  const prefix = (idx >= 0 ? src.slice(0, idx) : src).replace(/\s*$/, "") +
    "\n";
  // Names declared at 2-space indent in the interface(s) above the sentinel.
  const names = [...prefix.matchAll(/^ {2}([A-Za-z_$][\w$]*)\??:/gm)]
    .map((m) => m[1])
    .filter((n) => ident.test(n) && !RESERVED.has(n));
  const uniq = [...new Set(names)].sort((a, b) => a.localeCompare(b));
  const body = uniq
    .map((n) => `export const ${n} = vref(${JSON.stringify(n)});`)
    .join("\n");
  const region = `${SENTINEL}\n` +
    `import { type VarRef, varProxy } from "./template.ts";\n` +
    `const vref = <K extends keyof ${iface}>(k: K): VarRef<${iface}[K]> =>\n` +
    `  varProxy(k) as VarRef<${iface}[K]>;\n\n` +
    body + "\n";
  await Deno.writeTextFile(url, prefix + "\n" + region);
}

console.log(`Emitted bindings for ${MODS.length} registry modules.`);
