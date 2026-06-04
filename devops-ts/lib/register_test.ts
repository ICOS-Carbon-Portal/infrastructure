// Tests for register() result handles as a typed, drop-in replacement for the
// stringly-typed `expr("reg.field")` / `raw("reg.field ...")` references.
//
// These lock in the byte-identical equivalence the conversion relies on: a
// handle's `.ref` (value position) renders exactly like the expr() string, and
// the field itself (when/changed_when position) renders the bare dotted path.
// The safety win is structural — a handle must be `register()`ed and held in a
// `const`, so an unregistered name (the `_r` bug in icos.nextcloud/icos.zrepl)
// becomes a "Cannot find name" compile error instead of a silent no-op.
import { expr } from "./template.ts";
import { register } from "./register.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("register: .ref renders the value-position template", () => {
  const update = register("update");
  eq(
    update.backup_file.ref.toText(),
    "{{ update.backup_file }}",
    "backup_file.ref",
  );
});

Deno.test("register: .ref equals the expr() string it replaces", () => {
  const update = register("update");
  eq(
    update.backup_file.ref.toText(),
    expr("update.backup_file").toText(),
    "handle .ref == expr equivalence (drop-in for the icos.zrepl always: block)",
  );
});

Deno.test("register: field renders bare in when/changed_when position", () => {
  const r = register("r");
  eq(String(r.changed), "r.changed", "r.changed renders bare");
  eq(String(r.failed), "r.failed", "r.failed renders bare");
});

Deno.test("register: nested stat sub-result", () => {
  const st = register("st");
  eq(String(st.stat.exists), "st.stat.exists", "st.stat.exists bare");
  eq(st.stat.exists.ref.toText(), "{{ st.stat.exists }}", "st.stat.exists.ref");
});

Deno.test("register: name string is the bare register name", () => {
  const update = register("update");
  eq(String(update), "update", "the handle stringifies to its register name");
});
