// Tests for the lookup() helper: it must render byte-identically to the
// hand-written `expr("lookup('plugin', '...')")` strings it replaces.
import { expr, lookup, tmpl } from "./template.ts";
import { V } from "./vars.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("lookup: template plugin with a file-name literal", () => {
  eq(
    lookup("template", "borgmon.py").toText(),
    "{{ lookup('template', 'borgmon.py') }}",
    "template lookup",
  );
});

Deno.test("lookup: file plugin with a path literal", () => {
  eq(
    lookup("file", "roles/icos.flexpart/files/flexpart.pub").toText(),
    "{{ lookup('file', 'roles/icos.flexpart/files/flexpart.pub') }}",
    "file lookup",
  );
});

Deno.test("lookup: env plugin", () => {
  eq(
    lookup("env", "USER").toText(),
    "{{ lookup('env', 'USER') }}",
    "env lookup",
  );
});

Deno.test("lookup: vars plugin with a bare variable argument", () => {
  eq(
    lookup("vars", V.set_fact).toText(),
    "{{ lookup('vars', set_fact) }}",
    "vars lookup with a V.x arg renders the variable bare",
  );
});

Deno.test("lookup: splices into a tmpl literal as a ref part", () => {
  eq(
    tmpl`~${lookup("env", "USER")}/.ssh/config.icos`.toText(),
    "~{{ lookup('env', 'USER') }}/.ssh/config.icos",
    "lxd_vm ssh_config_file",
  );
});

Deno.test("lookup: matches the expr() string it replaces", () => {
  eq(
    lookup("template", "config.yaml").toText(),
    expr("lookup('template', 'config.yaml')").toText(),
    "lookup == expr equivalence",
  );
});
