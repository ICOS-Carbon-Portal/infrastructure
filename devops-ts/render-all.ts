// Render every TS module to YAML into an output directory that mirrors the
// devops/ layout. Each unit's devops-relative path (e.g. roles/icos.x/tasks/
// main.yml) becomes <outdir>/<that path>.
//
// By default the output is a COMPLETE mirror of devops' YAML: TS-backed files
// are rendered, and the .yml files with no TS counterpart (encrypted vaults,
// app payloads under files/templates, empty task files) are copied verbatim so
// the output has the same set of .yml files as devops. Pass --rendered-only to
// emit just the rendered files.
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
const origDir = new URL("../devops/", import.meta.url);

/** Write text to <outDir>/<rel>, creating parent directories. */
async function writeOut(rel: string, text: string) {
  const dest = new URL(rel, outDir);
  await Deno.mkdir(new URL(".", dest), { recursive: true });
  await Deno.writeTextFile(dest, text);
}

// Fresh output dir (refuse to clobber the devops source itself).
if (outDir.href === origDir.href) {
  console.error("error: output dir must not be the devops source dir");
  Deno.exit(2);
}
try {
  await Deno.remove(outDir, { recursive: true });
} catch { /* didn't exist */ }
await Deno.mkdir(outDir, { recursive: true });

const units = await collectUnits();
const renderedRels = new Set(units.map((u) => u.rel));

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

// Copy every devops .yml that has no TS counterpart, so the mirror is complete.
let copied = 0;
if (!renderedOnly) {
  async function walk(dir: URL, rel: string) {
    for await (const e of Deno.readDir(dir)) {
      const childRel = rel ? `${rel}/${e.name}` : e.name;
      if (e.isDirectory) {
        await walk(new URL(`${e.name}/`, dir), childRel);
      } else if (
        e.isFile && e.name.endsWith(".yml") && !renderedRels.has(childRel)
      ) {
        await writeOut(
          childRel,
          await Deno.readTextFile(new URL(childRel, origDir)),
        );
        copied++;
      }
    }
  }
  await walk(origDir, "");
}

console.log(`Rendered ${rendered} files to ${outArg}`);
if (!renderedOnly) console.log(`Copied ${copied} un-ported .yml verbatim`);
if (failures.length) {
  console.error(`\n${failures.length} failed:`);
  for (const f of failures) console.error(`  - ${f}`);
  Deno.exit(1);
}
