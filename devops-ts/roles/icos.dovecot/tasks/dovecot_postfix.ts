import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create domains file",
    blockinfile: {
      path: V.dovecot_domains_file,
      create: true,
      insertbefore: "BOF",
      marker: "# {mark} ansible - icos.dovecot",
      block: `# These are used both for 'relay_domains' and for 'transport_maps'
{% for domain in dovecot_domains %}
{{ domain }}\tlmtp:unix:private/{{ dovecot_lmtp | basename }}
{% endfor %}
`,
    },
    notify: "Reload postfix",
  },
  {
    name: "Make sure that postfix dbs exists",
    copy: {
      dest: V.item,
      force: false,
      content: "",
    },
    loop: ["/etc/postfix/transport", "/etc/postfix/virtual"],
    notify: "Reload postfix",
  },
  {
    name: "Compile postfix database files",
    command: tmpl`postmap ${V.item}`,
    changed_when: false,
    loop: [
      "/etc/postfix/transport",
      "/etc/postfix/virtual",
      V.dovecot_domains_file,
    ],
  },
  {
    name: "Configure postfix to use database files",
    postconf: {
      param: "{{ item.param }}",
      value: "{{ item.value }}",
      append: "{{ item.append | default(True) }}",
    },
    loop: [
      // Virtual alias domains is by default set to $virtual_alias_maps,
      // but it will conflict with relay_domains - "warning: do not list
      // domain test.icos-cp.eu in BOTH virtual_alias_domains and
      // relay_domains.
      { param: "virtual_alias_domains", value: "", append: false },
      { param: "virtual_alias_maps", value: "hash:/etc/postfix/virtual" },
      { param: "transport_maps", value: tmpl`hash:${V.dovecot_domains_file}` },
      { param: "relay_domains", value: tmpl`hash:${V.dovecot_domains_file}` },
    ],
  },
] satisfies TaskFile;
