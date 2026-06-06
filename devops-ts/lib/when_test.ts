// Tests for the extended when-helpers (Phase 1). Each asserts byte-exact
// rendering against a real expression from the raw() survey, so the eventual
// raw()->helper conversions stay byte-identical under `deno task verify`.
import {
  and,
  eq,
  group,
  isDefined,
  isIn,
  isNotDefined,
  isTruthy,
  isUndefined,
  isVersion,
  ne,
  not,
  notIn,
  or,
  truthy,
} from "./vars.ts";
import { V } from "./vars.ts";
import { register } from "./register.ts";

function eqs(actual: unknown, expected: string, msg: string): void {
  if (String(actual) !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("eq/ne: string literal renders quoted, ref renders bare", () => {
  eqs(
    eq(V.ansible_distribution, "Debian"),
    "ansible_distribution == 'Debian'",
    "eq",
  );
  eqs(
    ne(V.ansible_architecture, "x86_64"),
    "ansible_architecture != 'x86_64'",
    "ne",
  );
});

Deno.test("isDefined family: name string is bare; distinct undefined renderings", () => {
  eqs(
    isDefined("cpauth_domains"),
    "cpauth_domains is defined",
    "isDefined name",
  );
  eqs(
    isNotDefined("nebula_version"),
    "nebula_version is not defined",
    "isNotDefined",
  );
  eqs(
    isUndefined("podman_docker"),
    "podman_docker is undefined",
    "isUndefined",
  );
});

Deno.test("isDefined accepts a register-field ref", () => {
  const update = register("update");
  eqs(
    isDefined(update.backup_file),
    "update.backup_file is defined",
    "ref subject",
  );
});

Deno.test("truthy: bare var and register field", () => {
  eqs(truthy(V.nginx_metrics_enable), "nginx_metrics_enable", "bare var");
  const s = register("_service");
  eqs(truthy(s.changed), "_service.changed", "register .changed");
});

Deno.test("bool / default chains on Expr", () => {
  eqs(truthy(V.docker_upgrade).bool(), "docker_upgrade | bool", "| bool");
  eqs(
    truthy(V.nginx_metrics_enable).default(false).bool(),
    "nginx_metrics_enable | default(False) | bool",
    "default + bool",
  );
});

Deno.test("membership: ref collection and tuple literal", () => {
  eqs(
    isIn("smartmon", V.sexp_exporters),
    "'smartmon' in sexp_exporters",
    "in var",
  );
  eqs(
    notIn(V.vmagent_proxy, ["nginx", "caddy"]),
    "vmagent_proxy not in ('nginx', 'caddy')",
    "not in tuple",
  );
});

Deno.test("isTruthy / isVersion", () => {
  eqs(isTruthy("root_keys"), "root_keys is truthy", "is truthy");
  eqs(
    isVersion(V.ansible_kernel, "5.6", ">="),
    "ansible_kernel is version('5.6', '>=')",
    "is version",
  );
});

Deno.test("composition: not / or / group", () => {
  const r = register("_r");
  eqs(
    or(not(r.stat.exists), truthy(V.borg_upgrade)),
    "not _r.stat.exists or borg_upgrade",
    "not … or …",
  );
  eqs(
    not(group(truthy(V.docker_upgrade).default(false).bool())),
    "not (docker_upgrade | default(False) | bool)",
    "not (… | bool)",
  );
  eqs(
    and(isDefined("cpauth_domains"), not(V.nginx_metrics_enable)),
    "cpauth_domains is defined and not nginx_metrics_enable",
    "is defined and not …",
  );
});

Deno.test("asValue: render a condition in value position as {{ … }}", () => {
  const a = register("_config");
  const b = register("_jarfile");
  // set_fact / force_recreate boolean (cpmeta, fairdatapoint)
  eqs(
    or(a.changed, b.changed).asValue().toText(),
    "{{ _config.changed or _jarfile.changed }}",
    "or(...).asValue()",
  );
});
