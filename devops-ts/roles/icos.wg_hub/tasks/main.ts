import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { iff } from "../../../lib/template.ts";
import { and, not, or, truthy } from "../../../lib/vars.ts";
import { notVar, tmpl, V } from "../_ctx.ts";

const _hub_conf = register("_hub_conf");
const _spoke_conf = register("_spoke_conf");
const _reresolve = register("_reresolve");

export default [
  {
    name: "Install iptables-persistent",
    apt: {
      name: "iptables-persistent",
    },
  },
  {
    name: "Retrieve server's private key",
    shellfact: {
      exec: "cat /etc/wireguard/privatekey",
      fact: "_privatekey",
    },
  },
  {
    name: "Install wireguard hub config",
    when: truthy(V.wg_hub_ishub),
    register: _hub_conf,
    copy: {
      dest: tmpl`/etc/wireguard/${V.wg_hub_intf}.conf`,
      mode: 0o600,
      content: `[Interface]
Address = {{ wg_hub_self.addr }}
ListenPort = {{ wg_hub_config.hub.port }}
PrivateKey = {{ _privatekey }}

{% for name, conf in wg_hub_config.peers.items() %}
{% if name != inventory_hostname %}
# {{ name }}
[Peer]
PublicKey = {{ conf.key | default(lookup('file', '%s/%s' % (wg_hub_key_dir, name))) }}
AllowedIPs = {{ conf.allowed_ips | default("%s/32" % conf.addr) }}
PersistentKeepalive = 25
{% endif %}

{% endfor %}
`,
    },
  },
  {
    name: "Install wireguard spoke config",
    when: notVar("wg_hub_ishub"),
    register: _spoke_conf,
    copy: {
      dest: tmpl`/etc/wireguard/${V.wg_hub_intf}.conf`,
      mode: 0o600,
      content: `[Interface]
Address = {{ wg_hub_self.addr }}
{% if wg_hub_self.port is defined %}
ListenPort =  {{ wg_hub_self.port }}
{% endif %}
PrivateKey = {{ _privatekey }}

# {{ wg_hub_peer }}
[Peer]
PublicKey = {{ wg_hub_key }}
Endpoint = {{ wg_hub_addr -}}:{{ wg_hub_config.hub.port }}
AllowedIPs = {{ wg_hub_config.allowed_ips }}
PersistentKeepalive = 25
`,
    },
  },
  {
    name: "Add hosts",
    blockinfile: {
      marker: tmpl`# {mark} cloud.wg_hub ${V.wg_hub_config.name}`,
      path: "/etc/hosts",
      block: `{% for name, conf in wg_hub_config.peers.items() %}
{{ conf.addr }} {{ conf.name | default(name) }}.{{ wg_hub_intf }}
{% if name == wg_hub_peer %}
{{ conf.addr }} hub.{{ wg_hub_intf }}
{% endif %}
{% endfor %}
`,
    },
  },
  {
    name: "Allow wireguard through firewall",
    when: truthy(V.wg_hub_ishub),
    iptables_raw: {
      name: tmpl`wireguard_${V.wg_hub_config.name}`,
      rules: `-A INPUT -p udp --dport {{ wg_hub_port }} -j ACCEPT
-A FORWARD -i {{ wg_hub_intf }} -j ACCEPT
`,
    },
  },
  {
    name: "Allow all inbound traffic on the wireguard interface",
    iptables_raw: {
      name: tmpl`wireguard_${V.wg_hub_config.name}_allow_all`,
      state: iff(V.wg_hub_allow_all, "present", "absent"),
      rules: `-A INPUT -i {{ wg_hub_intf }} -j ACCEPT
`,
    },
  },
  {
    name: "Setup reresolve dependency",
    when: and(truthy(V.wg_hub_reresolve), not(V.wg_hub_ishub)),
    command:
      tmpl`systemctl add-wants wg-quick@${V.wg_hub_intf}.service wg-reresolve@${V.wg_hub_intf}.timer`,
    register: _reresolve,
    changed_when: _reresolve.stderr.startswith("Created symlink"),
  },
  {
    name: "Start wg-quick service",
    systemd: {
      name: tmpl`wg-quick@${V.wg_hub_intf}.service`,
      state: iff(
        or(_hub_conf.changed, _spoke_conf.changed, _reresolve.changed),
        "restarted",
        "started",
      ),
      enabled: true,
    },
  },
  {
    name: "Ping hub",
    command:
      tmpl`ping -c 1 -w 10 "${V.wg_hub_config.hub.peer}.${V.wg_hub_intf}"`,
    tags: "wg_hub_ping",
    changed_when: false,
  },
] satisfies TaskFile;
