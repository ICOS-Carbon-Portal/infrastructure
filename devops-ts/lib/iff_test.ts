// Tests for the iff() ternary combinator: it must render byte-identically to the
// hand-written `expr("'a' if cond else 'b'")` strings it replaces.
import { expr, iff } from "./template.ts";
import { and, eq as eqExpr, isIn, or, truthy, V } from "./vars.ts";
import { register } from "./register.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("iff: string branches with a single-var condition", () => {
  eq(
    iff(V.caddy_upgrade, "latest", "present").toText(),
    "{{ 'latest' if caddy_upgrade else 'present' }}",
    "quoted string branches, bare var condition",
  );
});

Deno.test("iff: var branch renders bare, string branch quoted", () => {
  eq(
    iff(V.caddy_modules, V.caddy_via_xcaddy, "/usr/bin/caddy").toText(),
    "{{ caddy_via_xcaddy if caddy_modules else '/usr/bin/caddy' }}",
    "caddy_bin",
  );
});

Deno.test("iff: omit branch (V.omit) renders bare", () => {
  eq(
    iff(V.restic_upgrade, V.omit, "/usr/local/bin/restic").toText(),
    "{{ omit if restic_upgrade else '/usr/local/bin/restic' }}",
    "restic creates",
  );
  eq(
    iff(V.nebula_hosts_enable, V.nebula_hosts_block, V.omit).toText(),
    "{{ nebula_hosts_block if nebula_hosts_enable else omit }}",
    "nebula hosts block",
  );
});

Deno.test("iff: comparison condition", () => {
  eq(
    iff(eqExpr(V.where, "EOF"), "EOF", V.omit).toText(),
    "{{ 'EOF' if where == 'EOF' else omit }}",
    "caddy insertafter",
  );
  eq(
    iff(isIn("smartmon", V.sexp_exporters), "docker", V.omit).toText(),
    "{{ 'docker' if 'smartmon' in sexp_exporters else omit }}",
    "script_exporter scripts",
  );
});

Deno.test("iff: numeric branches", () => {
  eq(
    iff(eqExpr(V.exploredata_type, "test"), 4567, 4566).toText(),
    "{{ 4567 if exploredata_type == 'test' else 4566 }}",
    "exploredata port",
  );
});

Deno.test("iff: register field condition renders bare", () => {
  const _service = register("_service");
  eq(
    iff(_service.changed, "yes", "no").toText(),
    "{{ 'yes' if _service.changed else 'no' }}",
    "daemon-reload",
  );
});

Deno.test("iff: compound register condition via or()", () => {
  const _jarfile = register("_jarfile");
  const _config = register("_config");
  eq(
    iff(or(_jarfile.changed, _config.changed), "restarted", "started").toText(),
    "{{ 'restarted' if _jarfile.changed or _config.changed else 'started' }}",
    "service state",
  );
});

Deno.test("iff: and() condition", () => {
  eq(
    and(truthy(V.caddy_upgrade), truthy(V.restic_upgrade)).toString(),
    "caddy_upgrade and restic_upgrade",
    "and helper sanity",
  );
});

Deno.test("iff: matches the expr() string it replaces", () => {
  // The canonical equivalence the conversion relies on.
  eq(
    iff(V.caddy_upgrade, "latest", "present").toText(),
    expr("'latest' if caddy_upgrade else 'present'").toText(),
    "iff == expr equivalence",
  );
});
