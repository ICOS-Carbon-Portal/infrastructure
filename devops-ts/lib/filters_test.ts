// Tests for the Template filter helpers added to drop expr() escapes
// for | join, | fileglob, and | map(attribute=...).
import { expr } from "./template.ts";
import { V } from "./vars.ts";
import { register } from "./register.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("join: list -> string", () => {
  eq(V.mtail_logs.join(",").toText(), "{{ mtail_logs | join(',') }}", "join");
});

Deno.test("fileglob + first + dirname chain", () => {
  eq(
    V.nebula_cert_sign.fileglob().first().dirname().toText(),
    "{{ nebula_cert_sign | fileglob | first | dirname }}",
    "nebula cert chdir",
  );
  eq(
    V.nebula_cert_sign.fileglob().first().dirname().toText(),
    expr("nebula_cert_sign | fileglob | first | dirname").toText(),
    "chain == expr equivalence",
  );
});

Deno.test("mapAttr on a register field .ref", () => {
  const find = register("_find");
  eq(
    find.files.ref.mapAttr("path").toText(),
    "{{ _find.files | map(attribute='path') }}",
    "mtail loop",
  );
});
