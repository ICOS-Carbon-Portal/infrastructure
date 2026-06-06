// Guard: no Jinja braces (`{{` / `{%`) may appear in an ordinary quoted string.
//
// Templated values must be structured — `V.x`, `tmpl`...``, `jinja`...``. The
// only places braces are allowed in a string literal are the argument of
// `jinjaLiteral("...")` (a literal-brace Jinja expression) and inside backtick
// template literals (tmpl/jinja-tagged composites and multi-line config-file
// bodies). This catches any hand-written or codemod-missed `{{` that slipped
// into a plain string.
//
//   deno run --allow-read check-braces.ts
const roots = ["roles", "playbooks", "data"].map((d) =>
  new URL(`./${d}/`, import.meta.url)
);

type Violation = { file: string; line: number; text: string };
const violations: Violation[] = [];

function scan(file: string, src: string) {
  let i = 0;
  const n = src.length;
  const lineAt = (idx: number) => src.slice(0, idx).split("\n").length;
  while (i < n) {
    const c = src[i];
    if (c === "/" && src[i + 1] === "/") {
      const e = src.indexOf("\n", i);
      i = e === -1 ? n : e;
      continue;
    }
    if (c === "/" && src[i + 1] === "*") {
      const e = src.indexOf("*/", i + 2);
      i = e === -1 ? n : e + 2;
      continue;
    }
    if (c === "`") { // template literal: exempt (tmpl composite or config body)
      let j = i + 1;
      while (j < n && src[j] !== "`") j += src[j] === "\\" ? 2 : 1;
      i = j + 1;
      continue;
    }
    if (c === '"' || c === "'") {
      let j = i + 1;
      while (j < n && src[j] !== c) j += src[j] === "\\" ? 2 : 1;
      const body = src.slice(i + 1, j);
      if (body.includes("{{") || body.includes("{%")) {
        // allowed only as the argument of jinjaLiteral(
        const before = src.slice(0, i).trimEnd();
        if (!before.endsWith("jinjaLiteral(")) {
          violations.push({ file, line: lineAt(i), text: `${c}${body}${c}` });
        }
      }
      i = j + 1;
      continue;
    }
    i++;
  }
}

async function walk(dir: URL) {
  let entries: Deno.DirEntry[] = [];
  try {
    for await (const e of Deno.readDir(dir)) entries.push(e);
  } catch {
    return;
  }
  for (const e of entries) {
    if (e.isDirectory) await walk(new URL(`${e.name}/`, dir));
    else if (e.isFile && e.name.endsWith(".ts")) {
      const url = new URL(e.name, dir);
      scan(
        url.pathname.replace(/.*\/devops-ts\//, ""),
        await Deno.readTextFile(url),
      );
    }
  }
}
for (const root of roots) await walk(root);

if (violations.length) {
  console.error(`✗ ${violations.length} string(s) contain Jinja braces:`);
  for (const v of violations) {
    console.error(`  ${v.file}:${v.line}  ${v.text}`);
  }
  console.error(
    '\nUse V.x / tmpl`...` / jinja`...` for templates, or jinjaLiteral("...") for literal braces.',
  );
  Deno.exit(1);
}
console.log("✓ no Jinja braces in plain strings");
