// Render a playbook module to YAML on stdout.
//
//   deno run --allow-all render.ts playbooks/keycloak.ts
import { render } from "./lib/ansible/render.ts";

const path = Deno.args[0];
if (!path) {
  console.error("usage: render.ts <playbook.ts>");
  Deno.exit(2);
}

const mod = await import(new URL(path, `file://${Deno.cwd()}/`).href);
const playbook = mod.default;
const yaml = await render(playbook);
await Deno.stdout.write(new TextEncoder().encode(yaml));
