import { eq, register, type TaskFile } from "../../../lib/ansible.ts";

const _r = register("_r");
import { tmpl, V } from "../_ctx.ts";

// Configuring client DNS resolution is much harder than setting up the DNS
// server.

// Depending on distribution is either openresolv + dnsmasq or systemd-networkd
// or NetworkManager (+ systemd). And maybe systemd-resolved.

// NetworkManager / systemd-networkd / systemd-resolved will all chat with each
// other over DBUS and sometimes they'll agree.

// To play on the hardest difficulty, add something like Mullvad VPN into the
// mix.

export default [
  // DHCPCD
  {
    when: eq(V.nebula_resolve_type, "probe"),
    block: [
      {
        name: "Query systemd for dhcpcd",
        systemd: { name: "dhcpcd" },
        register: _r,
      },
      {
        when: eq(_r.status.ActiveState, "active"),
        name: "Set nebula_resolve_type to dnsmasq",
        set_fact: { nebula_resolve_type: "dnsmasq", cacheable: true },
      },
    ],
  },
  // NETWORK MANAGER
  {
    when: eq(V.nebula_resolve_type, "probe"),
    block: [
      {
        name: "Query systemd for NetworkManager",
        systemd: { name: "NetworkManager" },
        register: _r,
      },
      {
        when: eq(_r.status.ActiveState, "active"),
        name: "Set nebula_resolve_type to NetworkManager",
        set_fact: { nebula_resolve_type: "NetworkManager", cacheable: true },
      },
    ],
  },
  // SYSTEMD-NETWORKD
  {
    when: eq(V.nebula_resolve_type, "probe"),
    block: [
      {
        name: "Query systemd for systemd-networkd",
        systemd: { name: "systemd-networkd" },
        register: _r,
      },
      {
        when: eq(_r.status.ActiveState, "active"),
        name: "Set nebula_resolve_type to systemd-networkd",
        set_fact: { nebula_resolve_type: "systemd-networkd", cacheable: true },
      },
    ],
  },
  // DEBIAN
  {
    when: [
      eq(V.nebula_resolve_type, "probe"),
      eq(V.ansible_distribution, "Debian"),
    ],
    set_fact: {
      name: "Set nebula_resolve_type to dnsmasq",
      nebula_resolve_type: "dnsmasq",
      cacheable: true,
    },
  },
  // UNKNOWN
  {
    when: eq(V.nebula_resolve_type, "probe"),
    set_fact: {
      name: "Set nebula_resolve_type to unknown",
      nebula_resolve_type: "unknown",
      cacheable: true,
    },
  },
  // INFO
  {
    name: "Inform about the client dns resolution setup",
    debug: {
      msg:
        tmpl`nebula_resolve_type == ${V.nebula_resolve_type} for ${V.ansible_lsb.id}/${V.ansible_lsb.major_release}`,
    },
  },
] satisfies TaskFile;
