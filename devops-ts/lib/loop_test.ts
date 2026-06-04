// Tests for the loop helpers, in particular the custom loop_var option that
// lets a task with `loop_control: { loop_var }` use typed item refs instead of
// expr("login.dst") strings.
import { loopOver, loopOverVar } from "./loop.ts";
import { expr, type Ref } from "./template.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("loopOver: default item var renders item.<key>", () => {
  const task = loopOver<{ src: string }>(
    [{ src: "a" }],
    (item) => ({ copy: { src: item.src } }),
  );
  // deno-lint-ignore no-explicit-any
  eq(String((task.copy as any).src), "{{ item.src }}", "item.src");
  if (task.loop_control) throw new Error("no loop_control without loopVar");
});

Deno.test("loopOverVar: custom loopVar renders <loopVar>.<key>", () => {
  const task = loopOverVar<{ dst: string; dst_port: string }>(
    expr("logins"),
    (login) => ({ vars: { d: login.dst, p: login.dst_port } }),
    { loopVar: "login" },
  );
  // deno-lint-ignore no-explicit-any
  const vars = task.vars as any;
  eq(String(vars.d), "{{ login.dst }}", "login.dst");
  eq(String(vars.p), "{{ login.dst_port }}", "login.dst_port");
});

Deno.test("loopOverVar: custom loopVar emits matching loop_control", () => {
  const task = loopOverVar<{ x: string }>(
    expr("things"),
    (thing) => ({ debug: { msg: thing.x } }),
    { loopVar: "thing" },
  );
  eq(
    JSON.stringify(task.loop_control),
    JSON.stringify({ loop_var: "thing" }),
    "loop_control loop_var",
  );
  // The looped item ref equals the expr() string it replaces.
  // deno-lint-ignore no-explicit-any
  const src: Ref = (task.debug as any).msg;
  eq(src.toText(), expr("thing.x").toText(), "thing.x == expr equivalence");
});
