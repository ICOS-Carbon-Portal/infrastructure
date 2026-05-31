// Codemod: wrap raw single-line "{{ ... }}" / "{% ... %}" string literals in
// tmpl(...), so they render as quoted scalars (type-driven, like V/tmpl values).
//
// Uses a small char-scanner (not regex masking) so that `//` inside a string —
// e.g. a URL `"https://{{ host }}/x"` — is never mistaken for a line comment.
// Backtick template literals (multi-line blocks) and line comments are skipped
// verbatim. Adds the needed `tmpl` import:
//   - role task/handler files: from "../_ctx.ts"
//   - playbooks/<f>.ts:        from "../lib/ansible.ts"
//   - playbooks/fixes/<f>.ts:  from "../../lib/ansible.ts"
//
//   deno run --allow-read --allow-write codemod-quote.ts

const roots = [
  new URL("./roles/", import.meta.url),
  new URL("./playbooks/", import.meta.url),
];

const isTemplate = (s: string) => s.includes("{{") || s.includes("{%");

/** Wrap qualifying string literals; returns [newText, changed]. */
function rewrite(src: string): [string, boolean] {
  let out = "";
  let changed = false;
  let i = 0;
  const n = src.length;
  while (i < n) {
    const c = src[i];
    // Line comment: copy to end of line.
    if (c === "/" && src[i + 1] === "/") {
      const nl = src.indexOf("\n", i);
      const end = nl === -1 ? n : nl;
      out += src.slice(i, end);
      i = end;
      continue;
    }
    // Block comment.
    if (c === "/" && src[i + 1] === "*") {
      const close = src.indexOf("*/", i + 2);
      const end = close === -1 ? n : close + 2;
      out += src.slice(i, end);
      i = end;
      continue;
    }
    // Template literal. Multi-line ones are block scalars (leave bare). A
    // single-line one holding a template should be quoted — turn `...` into the
    // tagged `tmpl`...`` (unless it's already tagged, e.g. existing tmpl`...`).
    if (c === "`") {
      let j = i + 1;
      while (j < n && src[j] !== "`") j += src[j] === "\\" ? 2 : 1;
      const lit = src.slice(i, j + 1);
      const inner = src.slice(i + 1, j);
      const alreadyTagged = /[A-Za-z0-9_$]$/.test(out); // e.g. tmpl`...`
      if (!alreadyTagged && !inner.includes("\n") && isTemplate(inner)) {
        out += `tmpl${lit}`;
        changed = true;
      } else {
        out += lit;
      }
      i = j + 1;
      continue;
    }
    // String literal (single or double quoted).
    if (c === '"' || c === "'") {
      let j = i + 1;
      while (j < n && src[j] !== c) j += src[j] === "\\" ? 2 : 1;
      const lit = src.slice(i, j + 1);
      const body = src.slice(i + 1, j);
      if (isTemplate(body)) {
        out += `tmpl(${lit})`;
        changed = true;
      } else {
        out += lit;
      }
      i = j + 1;
      continue;
    }
    out += c;
    i++;
  }
  return [out, changed];
}

/** Ensure `tmpl` is imported from `spec`; merge into an existing import or add one. */
function ensureTmpl(src: string, spec: string): string {
  const esc = spec.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  // Already imports tmpl from spec?
  const importRe = new RegExp(`import\\s*\\{([^}]*)\\}\\s*from\\s*"${esc}";`);
  const m = src.match(importRe);
  if (m) {
    const names = m[1].split(",").map((s) => s.trim()).filter(Boolean);
    if (names.includes("tmpl")) return src;
    names.push("tmpl");
    return src.replace(
      m[0],
      `import { ${names.sort().join(", ")} } from "${spec}";`,
    );
  }
  const imp = `import { tmpl } from "${spec}";`;
  const first = src.match(/^import .*?;$/m);
  return first
    ? src.replace(first[0], `${first[0]}\n${imp}`)
    : `${imp}\n${src}`;
}

function specFor(path: string): string {
  if (/\/roles\/[^/]+\/(tasks|handlers)\//.test(path)) return "../_ctx.ts";
  if (/\/playbooks\/fixes\//.test(path)) return "../../lib/ansible.ts";
  return "../lib/ansible.ts";
}

let changedFiles = 0;
async function walk(dir: URL) {
  for await (const e of Deno.readDir(dir)) {
    if (e.isDirectory) {
      await walk(new URL(`${e.name}/`, dir));
    } else if (e.isFile && e.name.endsWith(".ts") && e.name !== "_ctx.ts") {
      const url = new URL(e.name, dir);
      const original = await Deno.readTextFile(url);
      const [out, changed] = rewrite(original);
      if (!changed) continue;
      await Deno.writeTextFile(url, ensureTmpl(out, specFor(url.pathname)));
      changedFiles++;
    }
  }
}
for (const root of roots) await walk(root);
console.log(`Quoted templates in ${changedFiles} files.`);
