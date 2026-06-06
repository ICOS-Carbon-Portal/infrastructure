// Tests for concat(): a Jinja `+` expression, replacing expr("a + b").
import {
  concat,
  iff,
  jinjaLiteral,
  localVar,
  pct,
  randomInt,
} from "./template.ts";
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

Deno.test("concat: renders the canonical + expression", () => {
  eq(
    concat(V.dokku_static_domains, V.dokku_redirect_domains).toText(),
    "{{ dokku_static_domains + dokku_redirect_domains }}",
    "concat canonical render",
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

Deno.test("pct: python %-format (postgresql package name)", () => {
  eq(
    pct("postgresql-%s", V.postgresql_version).toText(),
    "{{ 'postgresql-%s' % postgresql_version }}",
    "postgresql-%s",
  );
  // inside a ternary (nfs4 firewall rule)
  eq(
    iff(V.nfs4_interface, pct("-i %s", V.nfs4_interface), "").toText(),
    "{{ '-i %s' % nfs4_interface if nfs4_interface else '' }}",
    "nfs4 -i %s",
  );
});

Deno.test("randomInt: seeded random filter on an int literal", () => {
  eq(
    randomInt(4, "bbserver").toText(),
    "{{ 4 | random(seed='bbserver') }}",
    "bbserver cron hour",
  );
});

Deno.test("localVar: typed task-local var reference", () => {
  eq(
    localVar<{ image: string }>("conf").image.toText(),
    "{{ conf.image }}",
    "jupyter registry image",
  );
});

Deno.test("jinjaLiteral: a literal-string Jinja expression", () => {
  // template-module delimiter overrides (just.ts)
  eq(jinjaLiteral("{{{{").toText(), "{{ '{{{{' }}", "four-brace start");
  eq(jinjaLiteral("}}}").toText(), "{{ '}}}' }}", "three-brace end");
});

Deno.test("regexEscape: ansible.builtin regex_escape filter", () => {
  eq(
    V.lxd_forward_ip.regexEscape().toText(),
    "{{ lxd_forward_ip | regex_escape }}",
    "lxd_forward regex",
  );
});
