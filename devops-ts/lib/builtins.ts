// Built-in Ansible variables ("magic vars" / facts) — always available,
// regardless of inventory or role. Kept separate from the user-defined `Vars`
// catalogue so the two can't be confused, and reference an undefined builtin
// is still a compile error.
//
// Add a builtin here when a converted playbook first references one.
export interface Builtins {
  /** True when the play is running in check mode (`--check`). */
  ansible_check_mode: boolean;
}
