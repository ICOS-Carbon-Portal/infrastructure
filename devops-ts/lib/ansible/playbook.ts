// Self-rendering playbook entrypoint.
//
// Wrap a playbook's plays with `playbook(import.meta, [...])`. The module is
// then both:
//   - importable — `playbook()` returns the typed `Playbook`, so `mod.default`
//     still works for verify.ts and anything else that consumes the data; and
//   - directly executable — `deno run playbooks/x.ts` renders the plays to YAML
//     on stdout (because `import.meta.main` is true only for the entry module).
//
// render-all.ts drives a fresh `deno run` per playbook, so each renders in its
// own process. That isolation is the point: module-level variable usage
// (globals, shared registries) is constrained to the one playbook that imports
// it instead of leaking across every playbook loaded into a single process.
import type { Playbook } from "./play.ts";
import { render } from "./render.ts";

/** Render `doc` to YAML on stdout, but only when this module is the entry point. */
export function renderToStdout(meta: ImportMeta, doc: unknown): void {
  if (!meta.main) return;
  render(doc as Playbook)
    .then(async (yaml) => {
      const bytes = new TextEncoder().encode(yaml);
      for (let n = 0; n < bytes.length;) {
        n += await Deno.stdout.write(bytes.subarray(n));
      }
    })
    .catch((e) => {
      console.error(e instanceof Error ? (e.stack ?? e.message) : String(e));
      Deno.exit(1);
    });
}

/**
 * Wrap a playbook's plays: returns them unchanged (for importers) and, when the
 * module is run directly, renders them to YAML on stdout.
 */
export function playbook(meta: ImportMeta, plays: Playbook): Playbook {
  renderToStdout(meta, plays);
  return plays;
}
