// Typed role references. Only roles go through a builder (`role()`), because
// that is what unlocks per-role parameter typing keyed off the role name.
import type { Roles } from "../roles.ts";
import type { Tags } from "./tags.ts";
import type { When } from "./task.ts";

/** Ansible role-keyword options (siblings of `role:`, not role variables). */
export interface RoleOpts {
  tags?: Tags;
  when?: When;
}

/** A flattened role reference as Ansible expects it: role + opts + variables. */
export type RoleRef = { role: string } & RoleOpts & Record<string, unknown>;

/**
 * A chainable role reference. Variables are fixed at construction (typed per
 * role); Ansible role-keyword options are attached fluently:
 *
 *   role("icos.nexus").tags("nexus")
 *   role("icos.cpauth").when(isDefined("cpauth_envries"))
 *   role("icos.virtuoso").tags("virtuoso").when(isDefined("virtuoso_enable").default(false))
 *
 * `toJSON()` emits the flat ref, so `render()`'s JSON round-trip drops the
 * methods and produces exactly the YAML Ansible expects.
 */
export class RoleBuilder {
  constructor(private readonly ref: RoleRef) {}

  /** Set `tags:` (a single tag or a list). */
  tags(tags: Tags): RoleBuilder {
    return new RoleBuilder({ ...this.ref, tags });
  }

  /** Set `when:` (a raw expression string or a built `Expr`). */
  when(when: When): RoleBuilder {
    return new RoleBuilder({ ...this.ref, when });
  }

  /** Set several role-keyword options at once. */
  opt(opts: RoleOpts): RoleBuilder {
    return new RoleBuilder({ ...this.ref, ...opts });
  }

  toJSON(): RoleRef {
    return this.ref;
  }
}

// When a role has no required variables, the vars argument is optional;
// otherwise it is mandatory. This is what makes `role("icos.matomo")` legal
// but `role("icos.keycloak")` a compile error (kc_hostname is required).
type RoleArgs<K extends keyof Roles> = Record<PropertyKey, never> extends
  Roles[K] ? [vars?: Roles[K]]
  : [vars: Roles[K]];

/**
 * Build a typed role reference. Variables are typed per role; attach tags/when
 * with the chainable `.tags()` / `.when()` helpers.
 *
 *   role("icos.keycloak", { kc_hostname: "keycloak.icos-cp.eu" })
 *   role("icos.nexus").tags("nexus")
 *   role("icos.matomo")
 */
export function role<K extends keyof Roles>(
  name: K,
  ...args: RoleArgs<K>
): RoleBuilder {
  const [vars] = args;
  return new RoleBuilder({ role: name, ...(vars ?? {}) });
}
