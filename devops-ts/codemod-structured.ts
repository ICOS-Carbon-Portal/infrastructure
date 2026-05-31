// Codemod: convert `tmpl(...)` calls to STRUCTURED form — every `{{ E }}` /
// `{% E %}` becomes an interpolation `${V.E}` (known bare var), `${expr("E")}`
// (canonical dynamic expr), or `${rawTmpl("…")}` (awkward: non-canonical
// spacing, statements, escapes — preserved verbatim). Literal text holds no
// braces afterwards.
//
// Handles both the flat form `tmpl("a {{ x }} b")` and tagged literals that
// still embed literal braces `tmpl`a ${V.y} {{ x }}``. Collapses a whole-value
// single ref to bare `V.x` / `expr("x")` / `rawTmpl("…")`. Skips data/ (handled
// by gen-data.ts) and multi-line plain backtick blocks (literal config bodies).
//
//   deno run --allow-read --allow-write codemod-structured.ts
import {
  isBareIdent,
  parseJinja,
  readInterpAt,
  type Segment,
} from "./lib/jinja-parse.ts";

const roots = [
  new URL("./roles/", import.meta.url),
  new URL("./playbooks/", import.meta.url),
];

// ---- known-name resolution (mirror of codemod-contexts ctxVars) ------------

function interfaceNames(text: string): Set<string> {
  const names = new Set<string>();
  for (const m of text.matchAll(/^\s{2}([A-Za-z_$][\w$]*)\??:/gm)) {
    names.add(m[1]);
  }
  return names;
}
const libDir = new URL("./lib/", import.meta.url);
const globals = interfaceNames(
  await Deno.readTextFile(new URL("globals.ts", libDir)),
);
const builtins = interfaceNames(
  await Deno.readTextFile(new URL("builtins.ts", libDir)),
);
const globalVars = interfaceNames(
  await Deno.readTextFile(new URL("vars.ts", libDir)),
);

async function knownFor(fileUrl: URL): Promise<Set<string>> {
  const path = fileUrl.pathname;
  const m = path.match(/\/roles\/([^/]+)\/(tasks|handlers)\//);
  if (m) {
    const ctx = await Deno.readTextFile(
      new URL(`./roles/${m[1]}/_ctx.ts`, import.meta.url),
    );
    return new Set([...interfaceNames(ctx), ...globals, ...builtins]);
  }
  // playbooks: `V` (from lib/ansible.ts) exposes only lib/vars.ts `Vars`.
  return new Set(globalVars);
}

// ---- emit helpers ----------------------------------------------------------

const used = new Set<string>();
const jsstr = (s: string) => JSON.stringify(s);
const backtickLit = (s: string) =>
  s.replace(/\\/g, "\\\\").replace(/`/g, "\\`").replace(/\$\{/g, "\\${");

/** Map one parsed Jinja segment to an interpolation expression (the `${...}` body). */
function segInterp(
  seg: Extract<Segment, { kind: "interp" }>,
  known: Set<string>,
): string {
  if (seg.canonical && seg.delim === "{{") {
    if (isBareIdent(seg.inner) && known.has(seg.inner)) {
      used.add("V");
      return `V.${seg.inner}`;
    }
    used.add("expr");
    return `expr(${jsstr(seg.inner)})`;
  }
  used.add("rawTmpl");
  return `rawTmpl(${jsstr(seg.raw)})`;
}

/**
 * Build the structured replacement. `lit` pieces are ALREADY backtick-ready
 * (escaped by the caller). Collapses a single interp (no literals) to a bare
 * call; otherwise a tagged tmpl`...`.
 */
function build(pieces: Array<{ lit: string } | { interp: string }>): string {
  const ps = pieces.filter((p) => "interp" in p || p.lit !== "");
  if (ps.length === 1 && "interp" in ps[0]) return ps[0].interp; // bare V/expr/rawTmpl
  if (ps.length === 0) return `tmpl\`\``;
  used.add("tmpl");
  let out = "tmpl`";
  for (const p of ps) out += "lit" in p ? p.lit : `\${${p.interp}}`;
  return out + "`";
}

/** Transform a flat `tmpl("...")` body (real chars). Lits must be escaped for backticks. */
function fromFlat(body: string, known: Set<string>): string {
  const pieces = parseJinja(body).map((seg) =>
    seg.kind === "lit"
      ? { lit: backtickLit(seg.text) }
      : { interp: segInterp(seg, known) }
  );
  return build(pieces);
}

/**
 * Transform a tagged literal body (raw backtick source). Operates in place:
 * copies `${...}` interpolations and `\x` escapes verbatim; replaces only the
 * `{{ }}` / `{% %}` substrings in literal regions. Returns null if none found.
 */
function fromTagged(tplBody: string, known: Set<string>): string | null {
  const pieces: Array<{ lit: string } | { interp: string }> = [];
  let lit = "";
  let i = 0;
  let sawBrace = false;
  const flush = () => {
    if (lit) pieces.push({ lit });
    lit = "";
  };
  while (i < tplBody.length) {
    if (tplBody[i] === "\\") { // backtick escape: keep verbatim
      lit += tplBody.slice(i, i + 2);
      i += 2;
      continue;
    }
    if (tplBody.startsWith("${", i)) { // existing interpolation: keep verbatim
      let depth = 1;
      let j = i + 2;
      while (j < tplBody.length && depth > 0) {
        if (tplBody[j] === "{") depth++;
        else if (tplBody[j] === "}") depth--;
        if (depth === 0) break;
        j++;
      }
      flush();
      pieces.push({ interp: tplBody.slice(i + 2, j) });
      i = j + 1;
      continue;
    }
    const r = readInterpAt(tplBody, i);
    if (r) {
      flush();
      sawBrace = true;
      pieces.push({ interp: segInterp(r.seg, known) });
      i = r.end;
      continue;
    }
    lit += tplBody[i];
    i++;
  }
  flush();
  return sawBrace ? build(pieces) : null;
}

// ---- scanner: find tmpl( and tmpl` calls -----------------------------------

function rewrite(src: string, known: Set<string>): string {
  let out = "";
  let i = 0;
  const n = src.length;
  const readString = (start: number): [string, number] => {
    const q = src[start];
    let j = start + 1;
    while (j < n && src[j] !== q) j += src[j] === "\\" ? 2 : 1;
    return [src.slice(start + 1, j), j + 1];
  };
  while (i < n) {
    const c = src[i];
    if (c === "/" && src[i + 1] === "/") {
      const e = src.indexOf("\n", i);
      const end = e === -1 ? n : e;
      out += src.slice(i, end);
      i = end;
      continue;
    }
    if (c === "/" && src[i + 1] === "*") {
      const e = src.indexOf("*/", i + 2);
      const end = e === -1 ? n : e + 2;
      out += src.slice(i, end);
      i = end;
      continue;
    }
    // tmpl( ... )  flat call with a single string literal arg (tolerate the
    // whitespace/newlines deno fmt may insert around the argument).
    if (src.startsWith("tmpl(", i) && !/[\w$]/.test(src[i - 1] ?? "")) {
      let k = i + 5;
      while (k < n && /\s/.test(src[k])) k++;
      const q = src[k];
      if (q === '"' || q === "'") {
        const [body, after] = readString(k);
        let m = after;
        while (m < n && /\s/.test(src[m])) m++;
        if (src[m] === ",") { // optional trailing comma
          m++;
          while (m < n && /\s/.test(src[m])) m++;
        }
        if (src[m] === ")") {
          out += fromFlat(unescapeJs(body, q), known);
          i = m + 1;
          continue;
        }
      }
    }
    // tmpl` ... `  tagged literal (single-line only; multi-line blocks untouched)
    if (src.startsWith("tmpl`", i) && !/[\w$]/.test(src[i - 1] ?? "")) {
      // find closing backtick, tracking ${ } and escapes
      let j = i + 5;
      let depth = 0;
      while (j < n) {
        const ch = src[j];
        if (ch === "\\") {
          j += 2;
          continue;
        }
        if (depth === 0 && ch === "`") break;
        if (src.startsWith("${", j)) {
          depth++;
          j += 2;
          continue;
        }
        if (depth > 0 && ch === "}") {
          depth--;
          j++;
          continue;
        }
        j++;
      }
      const tplBody = src.slice(i + 5, j);
      if (!tplBody.includes("\n")) {
        const replaced = fromTagged(tplBody, known);
        if (replaced !== null) {
          out += replaced;
          i = j + 1;
          continue;
        }
      }
      // unchanged: copy verbatim
      out += src.slice(i, j + 1);
      i = j + 1;
      continue;
    }
    // plain string / backtick / char: copy verbatim
    if (c === '"' || c === "'") {
      const [, after] = readString(i);
      out += src.slice(i, after);
      i = after;
      continue;
    }
    if (c === "`") {
      let j = i + 1;
      while (j < n && src[j] !== "`") j += src[j] === "\\" ? 2 : 1;
      out += src.slice(i, j + 1);
      i = j + 1;
      continue;
    }
    out += c;
    i++;
  }
  return out;
}

/** Decode a JS single/double-quoted string literal body to its real value. */
function unescapeJs(body: string, _q: string): string {
  let out = "";
  let i = 0;
  while (i < body.length) {
    if (body[i] === "\\" && i + 1 < body.length) {
      const c = body[i + 1];
      out += c === "n" ? "\n" : c === "t" ? "\t" : c === "r" ? "\r" : c; // \\, \", \', \`, etc. -> the literal char
      i += 2;
    } else {
      out += body[i];
      i++;
    }
  }
  return out;
}

// ---- import management (reuse codemod-contexts pattern) --------------------

function ensureImports(
  src: string,
  names: string[],
  roleFile: boolean,
  depth: string,
): string {
  if (names.length === 0) return src;
  const spec = roleFile ? "../_ctx.ts" : `${depth}lib/ansible.ts`;
  const esc = spec.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const re = new RegExp(`import\\s*\\{([^}]*)\\}\\s*from\\s*"${esc}";`);
  const m = src.match(re);
  if (m) {
    const have = new Set(m[1].split(",").map((s) => s.trim()).filter(Boolean));
    for (const nm of names) have.add(nm);
    return src.replace(
      m[0],
      `import { ${[...have].sort().join(", ")} } from "${spec}";`,
    );
  }
  const imp = `import { ${names.sort().join(", ")} } from "${spec}";`;
  const first = src.match(/^import .*?;$/m);
  return first
    ? src.replace(first[0], `${first[0]}\n${imp}`)
    : `${imp}\n${src}`;
}

// ---- driver ----------------------------------------------------------------

const only = Deno.args; // optional substring filters for safe testing
let changed = 0;
async function walk(dir: URL) {
  for await (const e of Deno.readDir(dir)) {
    if (e.isDirectory) {
      await walk(new URL(`${e.name}/`, dir));
    } else if (e.isFile && e.name.endsWith(".ts") && e.name !== "_ctx.ts") {
      const url = new URL(e.name, dir);
      if (only.length && !only.some((a) => url.pathname.includes(a))) continue;
      const src = await Deno.readTextFile(url);
      if (!/tmpl[(`]/.test(src)) continue;
      used.clear();
      const known = await knownFor(url);
      const out = rewrite(src, known);
      if (out === src) continue;
      const roleFile = /\/roles\/[^/]+\/(tasks|handlers)\//.test(url.pathname);
      const depth = /\/playbooks\/fixes\//.test(url.pathname)
        ? "../../"
        : "../";
      // helpers actually needed (role files get expr/rawTmpl from _ctx.ts).
      const names = [...used];
      const finalSrc = ensureImports(out, names, roleFile, depth);
      await Deno.writeTextFile(url, finalSrc);
      changed++;
    }
  }
}
for (const root of roots) await walk(root);
console.log(`Structured templates in ${changed} files.`);
