// Variable VALUES as they appear in task args, `vars:`/`set_fact`, and play vars.
import type { Template } from "../template.ts";

export type Scalar = string | number | boolean;

/** Any value a variable / module argument can hold: a scalar, a Jinja template
 * (`V.x`, `tmpl(...)`), null, or nested lists/maps of the same. */
export type VarValue =
  | Scalar
  | Template
  | null
  | VarValue[]
  | { [key: string]: VarValue };
