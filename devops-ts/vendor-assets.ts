// Vendor the un-portable devops .yml files into assets/, mirroring their paths.
//
// These are the files with no TS representation — encrypted vaults
// ($ANSIBLE_VAULT ciphertext), app payloads under roles/*/{files,templates}
// (docker-compose/schema/Jinja), and empty/comments-only task files. They can't
// be rendered from TS, so render-all copies them verbatim to complete the
// mirror. Vendoring them here lets render-all run without the devops/ source.
//
// Re-run whenever those source files change:
//   deno run --allow-read --allow-write --allow-env vendor-assets.ts
import { collectUnits } from "./lib/units.ts";

const origDir = new URL("../devops/", import.meta.url);
const assetsDir = new URL("./assets/", import.meta.url);

const rendered = new Set((await collectUnits()).map((u) => u.rel));

// Fresh assets dir.
try {
  await Deno.remove(assetsDir, { recursive: true });
} catch { /* didn't exist */ }
await Deno.mkdir(assetsDir, { recursive: true });

let copied = 0;
async function walk(dir: URL, rel: string) {
  for await (const e of Deno.readDir(dir)) {
    const childRel = rel ? `${rel}/${e.name}` : e.name;
    if (e.isDirectory) {
      await walk(new URL(`${e.name}/`, dir), childRel);
    } else if (
      e.isFile && e.name.endsWith(".yml") && !rendered.has(childRel)
    ) {
      const dest = new URL(childRel, assetsDir);
      await Deno.mkdir(new URL(".", dest), { recursive: true });
      await Deno.copyFile(new URL(childRel, origDir), dest);
      copied++;
    }
  }
}
await walk(origDir, "");

console.log(`Vendored ${copied} un-portable .yml into assets/`);
