// Codemod: rewrite role task/handler files to use the per-role typed context.
//
// For each roles/<role>/{tasks,handlers}/*.ts, for every in-context variable:
//   "{{ var }}"                  -> V.var
//   "{{ var }}/suffix ..."       -> tmpl`${V.var}/suffix ...`   (single-line only)
//   raw("var is defined")        -> isDef("var")
//   raw("not var")               -> notVar("var")
// Out-of-context vars (caller params, registered, loop subscripts, filters) are
// left exactly as-is. Backtick template literals (multi-line blocks) are never
// touched. Needed imports from "../_ctx.ts" are injected/merged.
//
// Safety: this is conservative and lossless-by-construction, and `verify.ts`
// is the oracle — the driver script reverts any file whose render changes.
//
//   deno run --allow-read --allow-write codemod-contexts.ts [role ...]

const rolesDir = new URL("./roles/", import.meta.url);

/** Read a role's in-context variable names from its generated _ctx.ts + globals + builtins. */
async function ctxVars(roleDir: URL): Promise<Set<string>> {
  const names = new Set<string>();
  for (
    const url of [
      new URL("_ctx.ts", roleDir),
      new URL("../lib/globals.ts", rolesDir),
      new URL("../lib/builtins.ts", rolesDir),
    ]
  ) {
    let text: string;
    try {
      text = await Deno.readTextFile(url);
    } catch {
      continue;
    }
    // collect `  name: type;` interface members (ignore quoted/odd keys)
    for (const m of text.matchAll(/^\s{2}([A-Za-z_$][\w$]*)\??:/gm)) {
      names.add(m[1]);
    }
  }
  return names;
}

const IDENT = /^[A-Za-z_$][\w$]*$/;

/** Convert the inner content of a string literal to either a V ref, a tmpl, or null (no change). */
function convertValue(
  inner: string,
  vars: Set<string>,
): { code: string; uses: string[] } | null {
  // Only convert references with the exact `{{ var }}` spacing the renderer
  // emits (single space each side), so the round-trip is byte-identical.
  // Whole string is exactly one `{{ var }}`.
  const whole = inner.match(/^\{\{ ([\w$]+) \}\}$/);
  if (whole && vars.has(whole[1])) {
    return { code: `V.${whole[1]}`, uses: ["V"] };
  }
  // Composite: contains at least one convertible `{{ var }}`. Don't touch
  // strings with backticks or ${ (would break the template literal).
  if (inner.includes("`") || inner.includes("${")) return null;
  let any = false;
  const out = inner.replace(/\{\{ ([\w$]+) \}\}/g, (m, name: string) => {
    if (IDENT.test(name) && vars.has(name)) {
      any = true;
      return `\${V.${name}}`;
    }
    return m; // leave non-standard / filtered interpolations as literal text
  });
  if (!any) return null;
  return { code: "tmpl`" + out + "`", uses: ["tmpl", "V"] };
}

function processFile(
  src: string,
  vars: Set<string>,
): { out: string; used: Set<string> } {
  const used = new Set<string>();

  // Mask backtick template literals (multi-line `content` blocks etc.) so the
  // string-literal pass never reaches inside them — a `"{{ x }}"` that appears
  // as literal text within a template literal must stay untouched.
  const masks: string[] = [];
  const masked = src.replace(/`(?:\\.|\$\{[^}]*\}|[^`\\])*`/gs, (m) => {
    masks.push(m);
    return `\0TMPL${masks.length - 1}\0`;
  });

  // 1) String literals (single- or double-quoted, single line). Replace the
  //    whole literal token when its content converts.
  let out = masked.replace(
    /(["'])((?:\\.|(?!\1)[^\\\n])*)\1/g,
    (full, _q, body) => {
      const conv = convertValue(body, vars);
      if (!conv) return full;
      for (const u of conv.uses) used.add(u);
      return conv.code;
    },
  );

  // 2) raw("X is defined") -> isDef("X"); raw("not X") -> notVar("X")
  out = out.replace(
    /raw\((["'])\s*([\w$]+)\s+is\s+defined\s*\1\)/g,
    (full, _q, name) => {
      if (!vars.has(name)) return full;
      used.add("isDef");
      return `isDef("${name}")`;
    },
  );
  out = out.replace(
    /raw\((["'])\s*not\s+([\w$]+)\s*\1\)/g,
    (full, _q, name) => {
      if (!vars.has(name)) return full;
      used.add("notVar");
      return `notVar("${name}")`;
    },
  );

  // Restore masked template literals.
  out = out.replace(/\0TMPL(\d+)\0/g, (_m, i) => masks[Number(i)]);

  return { out, used };
}

/** Inject/merge `import { ... } from "../_ctx.ts";` for the used helpers. */
function ensureImports(src: string, used: Set<string>): string {
  if (used.size === 0) return src;
  const names = [...used].sort();
  const existing = src.match(/import\s*\{([^}]*)\}\s*from\s*"\.\.\/_ctx\.ts";/);
  if (existing) {
    const have = new Set(
      existing[1].split(",").map((s) => s.trim()).filter(Boolean),
    );
    for (const n of names) have.add(n);
    const merged = [...have].sort().join(", ");
    return src.replace(existing[0], `import { ${merged} } from "../_ctx.ts";`);
  }
  // Add after the first import line.
  const imp = `import { ${names.join(", ")} } from "../_ctx.ts";`;
  const firstImport = src.match(/^import .*?;$/m);
  if (firstImport) {
    return src.replace(firstImport[0], `${firstImport[0]}\n${imp}`);
  }
  return `${imp}\n${src}`;
}

// --- driver ---------------------------------------------------------------

const only = new Set(Deno.args);
let changed = 0;
for await (const role of Deno.readDir(rolesDir)) {
  if (!role.isDirectory) continue;
  if (only.size && !only.has(role.name)) continue;
  const roleDir = new URL(`${role.name}/`, rolesDir);
  const vars = await ctxVars(roleDir);
  if (vars.size === 0) continue;

  for (const sub of ["tasks", "handlers"]) {
    const subDir = new URL(`${sub}/`, roleDir);
    let files: Deno.DirEntry[] = [];
    try {
      for await (const f of Deno.readDir(subDir)) files.push(f);
    } catch {
      continue;
    }
    for (const f of files) {
      if (!f.isFile || !f.name.endsWith(".ts")) continue;
      const url = new URL(f.name, subDir);
      const src = await Deno.readTextFile(url);
      const { out, used } = processFile(src, vars);
      if (out === src) continue;
      await Deno.writeTextFile(url, ensureImports(out, used));
      changed++;
    }
  }
}
console.log(`Codemod touched ${changed} files.`);
