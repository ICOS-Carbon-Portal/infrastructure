// A test-only `V` accessor that permits ANY variable name. The production global
// `V` (lib/vars.ts) only exposes the shared + registry surface; tests exercise
// rendering mechanics with arbitrary fixture names, so they use this instead.
import { type Ref, varProxy } from "./template.ts";

export const V = new Proxy({}, {
  get: (_t, name: string) => varProxy(name),
}) as Record<string, Ref>;
