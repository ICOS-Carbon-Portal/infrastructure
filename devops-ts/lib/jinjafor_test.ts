// Tests for jinjaFor(), which replaces the {% for %} / loop-body / {% endfor %}
// trio with one construct whose iterable and loop-var references are checked;
// and for jinja``, the checked-interpolation verbatim fragment.
import { jinja, jinjaFor, tmpl } from "./template.ts";
import { register } from "./register.ts";
import { V } from "./test-v.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

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
    "full caddy command byte-identical to the original",
  );
});

Deno.test("jinja: control-flow verbatim, refs checked & rendered bare", () => {
  // {% if %} with whitespace-control; the variable is a checked ${V.x}
  eq(
    jinja`{% if ${V.lxd_vm_docker} -%}`.toText(),
    "{% if lxd_vm_docker -%}",
    "if with trim marker",
  );
  // whitespace-controlled ref
  eq(
    jinja`{{ ${V._dbin_src} -}}`.toText(),
    "{{ _dbin_src -}}",
    "trimmed ref",
  );
  // a register field path renders bare inside a filter/bracket chain
  const fs = register("_fs");
  eq(
    jinja`{{ (${fs.files.ref} | sort(attribute='path') | last).path }}`
      .toText(),
    "{{ (_fs.files | sort(attribute='path') | last).path }}",
    "quince tomcat dir",
  );
});

Deno.test("jinja: splices verbatim into an outer tmpl", () => {
  eq(
    tmpl`${jinja`{% if ${V.lxd_vm_docker} -%}`}x${jinja`{% endif -%}`}`
      .toText(),
    "{% if lxd_vm_docker -%}x{% endif -%}",
    "if/endif around a literal",
  );
});
