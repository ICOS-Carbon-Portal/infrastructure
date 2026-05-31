// Render every TS module to YAML into an output directory that mirrors the
// devops/ layout. Each unit's devops-relative path (e.g. roles/icos.x/tasks/
// main.yml) becomes <outdir>/<that path>.
//
// Self-contained: does NOT need the devops/ source. By default the output is a
// COMPLETE mirror — TS-backed files are rendered, and the un-portable .yml
// (encrypted vaults, app payloads under files/templates, empty task files),
// pre-vendored into assets/ by vendor-assets.ts, are copied verbatim so the
// output has the same set of .yml files as devops. Pass --rendered-only to emit
// just the rendered files (assets/ then not needed at all).
//
//   deno run --allow-read --allow-write render-all.ts [outdir] [--rendered-only]
//   deno task render-all ../devops-rendered
import { render } from "./lib/ansible.ts";
import { collectUnits } from "./lib/units.ts";

const flags = Deno.args.filter((a) => a.startsWith("--"));
const positional = Deno.args.filter((a) => !a.startsWith("--"));
const renderedOnly = flags.includes("--rendered-only");

const outArg = positional[0] ?? "../devops-rendered";
const outDir = new URL(
  outArg.endsWith("/") ? outArg : `${outArg}/`,
  // resolve relative to the current working directory
  `file://${Deno.cwd()}/`,
);
const assetsDir = new URL("./assets/", import.meta.url);

/** Write text to <outDir>/<rel>, creating parent directories. */
async function writeOut(rel: string, text: string) {
  const dest = new URL(rel, outDir);
  await Deno.mkdir(new URL(".", dest), { recursive: true });
  await Deno.writeTextFile(dest, text);
}

// Refuse to clobber the project's own source dirs.
for (const guard of [assetsDir, new URL("./", import.meta.url)]) {
  if (outDir.href === guard.href) {
    console.error("error: refusing to write output into a source directory");
    Deno.exit(2);
  }
}
try {
  await Deno.remove(outDir, { recursive: true });
} catch { /* didn't exist */ }
await Deno.mkdir(outDir, { recursive: true });

const units = await collectUnits();

let rendered = 0;
const failures: string[] = [];
for (const unit of units) {
  try {
    const mod = await import(unit.ts.href);
    await writeOut(unit.rel, await render(mod.default));
    rendered++;
  } catch (e) {
    failures.push(`${unit.label}: ${e instanceof Error ? e.message : e}`);
  }
}

// Copy the vendored un-portable .yml (assets/) verbatim to complete the mirror.
// Sourced from assets/, so no devops/ dependency.
let copied = 0;
if (!renderedOnly) {
  async function walk(dir: URL, rel: string) {
    let entries: Deno.DirEntry[] = [];
    try {
      for await (const e of Deno.readDir(dir)) entries.push(e);
    } catch {
      return; // assets/ not vendored yet
    }
    for (const e of entries) {
      const childRel = rel ? `${rel}/${e.name}` : e.name;
      if (e.isDirectory) {
        await walk(new URL(`${e.name}/`, dir), childRel);
      } else if (e.isFile && e.name.endsWith(".yml")) {
        await writeOut(
          childRel,
          await Deno.readTextFile(new URL(childRel, assetsDir)),
        );
        copied++;
      }
    }
  }
  await walk(assetsDir, "");
}

console.log(`Rendered ${rendered} files to ${outArg}`);
if (!renderedOnly) console.log(`Copied ${copied} un-ported .yml verbatim`);
if (failures.length) {
  console.error(`\n${failures.length} failed:`);
  for (const f of failures) console.error(`  - ${f}`);
  Deno.exit(1);
}
