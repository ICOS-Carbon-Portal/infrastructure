import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check status of certificate",
    command: tmpl`ops-nebula cert-check ${V.nebula_cert_min_days}`,
    changed_when: false,
    register: "status",
  },
  {
    name: "Cert status",
    debug: {
      msg: `{{status.stdout_lines[0]}}
`,
    },
    when: raw("status.stdout_lines"),
  },
  {
    when: raw('status.stdout and status.stdout_lines[-1] == "need to sign"'),
    block: [
      {
        name: "Retrieve public key",
        slurp: { src: "/etc/nebula/new.pub" },
        register: "newpub",
      },
      {
        delegate_to: "localhost",
        name: "Sign pubkey to create certificate",
        expect: {
          // Use fileglob to search for the nebula certificate directory, then
          // switch to that directory.
          chdir: tmpl("{{ nebula_cert_sign | fileglob | first | dirname }}"),
          // Create new certificate with a duration 1 second less than the CA's.
          command:
            tmpl`/bin/bash -c 'nebula-cert sign -ca-crt {{nebula_cert_sign | basename}} -ca-key {{nebula_cert_sign | basename | splitext | first}}.key -in-pub <(echo "{{ newpub.content | b64decode }}") -ip {{ nebula_ip }}{{ nebula_netmask }} -name {{ nebula_hostname }} -out-crt crt.sign && cat crt.sign && rm crt.sign'`,
          // We default to an empty passphrase, so it'll work by default for keys
          // with no password.
          responses: {
            "Enter passphrase: ": tmpl(
              "{{ nebula_passphrase | default ('') }}",
            ),
          },
        },
        register: "signedcert",
      },
      {
        name: "Write signed certificate",
        copy: {
          dest: "/etc/nebula/new.crt",
          content: tmpl("{{ signedcert.stdout }}"),
        },
      },
      {
        name: "Pick up new status",
        command: tmpl`ops-nebula cert-check ${V.nebula_cert_min_days}`,
        register: "status",
        changed_when: 'status.stdout_lines[-1] == "need to restart"',
        notify: "restart nebula",
      },
    ],
  },
] satisfies TaskFile;
