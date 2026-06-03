// Built-in Ansible variables ("magic vars" / facts) — always available,
// regardless of inventory or role. Kept separate from the user-defined `Vars`
// catalogue so the two can't be confused, and reference an undefined builtin
// is still a compile error.
//
// Add a builtin here when a converted playbook first references one.
export interface BuiltinVars {
  /** True when the play is running in check mode (`--check`). */
  ansible_check_mode: boolean;

  // Connection / host magic vars.
  inventory_hostname: string;
  inventory_hostname_short: string;
  ansible_host: string;
  ansible_user: string;
  ansible_port: string;
  playbook_dir: string;
  role_path: string;
  role_name: string;
  groups: unknown;
  group_names: unknown;
  hostvars: unknown;
  /** The "skip this argument" sentinel: `foo: "{{ omit }}"` omits the arg. */
  omit: string;
  play_hosts: unknown;
  ansible_play_hosts: unknown;

  // The current loop element (within a `loop:`/`with_*` task). Subscripts like
  // `item.x` are dynamic and stay raw; the bare name is checkable.
  item: unknown;

  // Common gathered facts.
  ansible_distribution: string;
  ansible_distribution_release: string;
  ansible_distribution_version: string;
  ansible_distribution_major_version: string;
  ansible_distribution_file_variety: string;
  ansible_os_family: string;
  ansible_architecture: string;
  ansible_machine: string;
  ansible_hostname: string;
  ansible_fqdn: string;
  ansible_kernel: string;
  ansible_lsb: {
    id: string;
    codename: string;
    release: string;
    major_release: string;
  };
  ansible_default_ipv4: { gateway: string };
  ansible_python: { version: { major: string; minor: string } };
  ansible_default_ipv6: unknown;
  ansible_facts: unknown;
  ansible_date_time: unknown;
  ansible_env: unknown;
  ansible_processor_vcpus: number;
  ansible_memtotal_mb: number;
}
