// Tests for concat(): a Jinja `+` expression, replacing expr("a + b").
import { concat, expr } from "./template.ts";
import { V } from "./vars.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("concat: two var refs render bare, joined by +", () => {
  eq(
    concat(V.jupyter_domains, V.ganymede_domains).toText(),
    "{{ jupyter_domains + ganymede_domains }}",
    "ganymede certbot_domains",
  );
});

Deno.test("concat: matches the expr() string it replaces", () => {
  eq(
    concat(V.dokku_static_domains, V.dokku_redirect_domains).toText(),
    expr("dokku_static_domains + dokku_redirect_domains").toText(),
    "concat == expr equivalence",
  );
});

Deno.test("concat: variadic (3+ parts)", () => {
  eq(
    concat(V.jupyter_domains, V.ganymede_domains, V.dokku_static_domains)
      .toText(),
    "{{ jupyter_domains + ganymede_domains + dokku_static_domains }}",
    "three-way concat",
  );
});
