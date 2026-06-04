// Tests for binding() and jinjaFor(), which replace expr() in the previously
// "irreducible" cases: a task-local vars: reference, and a {% for %} loop.
import { binding, expr, jinjaFor, tmpl } from "./template.ts";
import { V } from "./vars.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("binding: typed reference to a local var name", () => {
  eq(
    binding<{ image: string }>("conf").image.toText(),
    "{{ conf.image }}",
    "jupyter conf.image",
  );
  eq(
    binding<{ image: string }>("conf").image.toText(),
    expr("conf.image").toText(),
    "binding == expr equivalence",
  );
});

Deno.test("jinjaFor: {% for %} with a typed loop var and checked iterable", () => {
  eq(
    jinjaFor<string>("module", V.caddy_modules, (m) => tmpl` --with ${m} `)
      .toText(),
    "{% for module in caddy_modules %} --with {{ module }} {% endfor %}",
    "caddy xcaddy build loop",
  );
});

Deno.test("jinjaFor: splices verbatim into an outer tmpl", () => {
  eq(
    tmpl`xcaddy build --output ${V.caddy_via_xcaddy} ${
      jinjaFor<string>("module", V.caddy_modules, (m) => tmpl` --with ${m} `)
    }`.toText(),
    "xcaddy build --output {{ caddy_via_xcaddy }} {% for module in caddy_modules %} --with {{ module }} {% endfor %}",
    "full caddy command byte-identical to the expr/rawTmpl original",
  );
});
