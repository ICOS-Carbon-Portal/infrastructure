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
  ansible_ssh_host_key_ecdsa_public: string;
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

  /** Custom `icos` facts (set by the icos fact module): host-environment flags. */
  icos: {
    inside_lxd: boolean;
    root_is_zfs: boolean;
  };
}

// === auto-generated variable bindings (gen-bindings.ts); do not edit below ===
import { varProxy, type VarRef } from "./template.ts";
const vref = <K extends keyof BuiltinVars>(k: K): VarRef<BuiltinVars[K]> =>
  varProxy(k) as VarRef<BuiltinVars[K]>;

export const ansible_architecture = vref("ansible_architecture");
export const ansible_check_mode = vref("ansible_check_mode");
export const ansible_date_time = vref("ansible_date_time");
export const ansible_default_ipv4 = vref("ansible_default_ipv4");
export const ansible_default_ipv6 = vref("ansible_default_ipv6");
export const ansible_distribution = vref("ansible_distribution");
export const ansible_distribution_file_variety = vref(
  "ansible_distribution_file_variety",
);
export const ansible_distribution_major_version = vref(
  "ansible_distribution_major_version",
);
export const ansible_distribution_release = vref(
  "ansible_distribution_release",
);
export const ansible_distribution_version = vref(
  "ansible_distribution_version",
);
export const ansible_env = vref("ansible_env");
export const ansible_facts = vref("ansible_facts");
export const ansible_fqdn = vref("ansible_fqdn");
export const ansible_host = vref("ansible_host");
export const ansible_hostname = vref("ansible_hostname");
export const ansible_kernel = vref("ansible_kernel");
export const ansible_lsb = vref("ansible_lsb");
export const ansible_machine = vref("ansible_machine");
export const ansible_memtotal_mb = vref("ansible_memtotal_mb");
export const ansible_os_family = vref("ansible_os_family");
export const ansible_play_hosts = vref("ansible_play_hosts");
export const ansible_port = vref("ansible_port");
export const ansible_processor_vcpus = vref("ansible_processor_vcpus");
export const ansible_python = vref("ansible_python");
export const ansible_ssh_host_key_ecdsa_public = vref(
  "ansible_ssh_host_key_ecdsa_public",
);
export const ansible_user = vref("ansible_user");
export const group_names = vref("group_names");
export const groups = vref("groups");
export const hostvars = vref("hostvars");
export const icos = vref("icos");
export const inventory_hostname = vref("inventory_hostname");
export const inventory_hostname_short = vref("inventory_hostname_short");
export const item = vref("item");
export const omit = vref("omit");
export const play_hosts = vref("play_hosts");
export const playbook_dir = vref("playbook_dir");
export const role_name = vref("role_name");
export const role_path = vref("role_path");
