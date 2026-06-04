import { raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, rawTmpl, tmpl, V } from "../_ctx.ts";

const newpub = register("newpub");
const signedcert = register("signedcert");

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
        register: newpub,
      },
      {
        delegate_to: "localhost",
        name: "Sign pubkey to create certificate",
        expect: {
          // Use fileglob to search for the nebula certificate directory, then
          // switch to that directory.
          chdir: V.nebula_cert_sign.fileglob().first().dirname(),
          // Create new certificate with a duration 1 second less than the CA's.
          command: tmpl`/bin/bash -c 'nebula-cert sign -ca-crt ${
            rawTmpl("{{nebula_cert_sign | basename}}")
          } -ca-key ${
            rawTmpl("{{nebula_cert_sign | basename | splitext | first}}")
          }.key -in-pub <(echo "${newpub.content.ref.b64decode()}") -ip ${V.nebula_ip}${V.nebula_netmask} -name ${V.nebula_hostname} -out-crt crt.sign && cat crt.sign && rm crt.sign'`,
          // We default to an empty passphrase, so it'll work by default for keys
          // with no password.
          responses: {
            "Enter passphrase: ": expr("nebula_passphrase | default ('')"),
          },
        },
        register: signedcert,
      },
      {
        name: "Write signed certificate",
        copy: {
          dest: "/etc/nebula/new.crt",
          content: signedcert.stdout.ref,
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
