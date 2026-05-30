import { loopOver, raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install opendkim",
    apt: {
      name: [
        "opendkim",
        "opendkim-tools",
      ],
    },
  },
  {
    name: "Create keys directory",
    file: {
      path: V.opendkim_keys,
      mode: 0o700,
      state: "directory",
      owner: V.opendkim_user,
      group: V.opendkim_user,
    },
  },
  {
    name: "Create opendkim.conf",
    template: {
      dest: "/etc/opendkim.conf",
      src: "opendkim.conf",
      lstrip_blocks: true,
    },
    notify: "Restart opendkim",
  },
  {
    name: "Create config files",
    template: {
      dest: "/etc/opendkim",
      src: V.item,
      lstrip_blocks: true,
    },
    loop: [
      "signing.table",
      "key.table",
      "trusted.hosts",
    ],
    notify: "Restart opendkim",
  },
  {
    name: "Create key directory for domain",
    file: {
      path: tmpl`${V.opendkim_keys}/${V.item}`,
      state: "directory",
      owner: V.opendkim_user,
      group: V.opendkim_user,
    },
    loop: "{{ opendkim_domains }}",
  },
  {
    name: "Create domain keys",
    become: true,
    become_user: V.opendkim_user,
    command:
      tmpl`opendkim-genkey -b 2048 -d ${V.item} -s default -v && chmod 600 default.private`,
    args: {
      chdir: tmpl`${V.opendkim_keys}/${V.item}`,
      creates: "default.private",
    },
    loop: "{{ opendkim_domains }}",
  },
  {
    name: "Find domain keys that needs to be added to DNS",
    "ansible.builtin.shell":
      `for d in {{ opendkim_domains | difference(opendkim_domains_testkeys) | join(" ") }}; do
  echo -n "default._domainkey $d ";
  cat {{ opendkim_keys }}/$d/default.txt | sed -n 'N;N;s/.*( //g;s/\\x0A/ /g;s/).*//g;s/"[[:blank:]]*"//g;s/"//g;p';
done`,
    register: "_r",
    changed_when: false,
    when: raw("opendkim_domains | difference(opendkim_domains_testkeys)"),
  },
  {
    name: "Print instructions about adding DNS records",
    debug: {
      msg: `Create the following DNS records:
"{{ _r.stdout }}"
`,
    },
    when: raw("opendkim_domains | difference(opendkim_domains_testkeys)"),
  },
  {
    name: "Run opendkim-testkey on keys that have been added to DNS",
    command: tmpl`opendkim-testkey -d ${V.item} -s default -vvv`,
    changed_when: false,
    loop: V.opendkim_domains_testkeys,
  },
  {
    name: "Create socket directory",
    file: {
      path: "{{ opendkim_sock | dirname }}",
      state: "directory",
      owner: "opendkim",
      group: "postfix",
    },
  },
  loopOver<{ param: string; value: string; append?: boolean }>(
    [
      {
        param: "smtpd_milters",
        value: "local:opendkim/opendkim.sock",
        append: true,
      },
      {
        param: "non_smtpd_milters",
        value: "$smtpd_milters",
      },
    ],
    (item) => ({
      name: "Configure postfix",
      postconf: {
        param: item.param,
        value: item.value,
        append: "{{ item.append | default(omit) }}",
      },
      notify: "Restart postfix",
    }),
  ),
  {
    name: "Add postfix to the opendkim group",
    user: {
      name: "postfix",
      append: true,
      groups: [
        "opendkim",
      ],
    },
    notify: "Restart postfix",
  },
] satisfies TaskFile;
