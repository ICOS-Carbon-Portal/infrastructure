// Tests for the Template filter helpers added to drop expr() escapes
// for | join, | fileglob, and | map(attribute=...).
import { V } from "./test-v.ts";
import { register } from "./register.ts";

function eq(actual: string, expected: string, msg: string): void {
  if (actual !== expected) {
    throw new Error(`${msg}\n  expected: ${expected}\n  actual:   ${actual}`);
  }
}

Deno.test("join: list -> string", () => {
  eq(V.mtail_logs.join(",").toText(), "{{ mtail_logs | join(',') }}", "join");
});

Deno.test("fileglob + first + dirname chain", () => {
  eq(
    V.nebula_cert_sign.fileglob().first().dirname().toText(),
    "{{ nebula_cert_sign | fileglob | first | dirname }}",
    "nebula cert chdir",
  );
  eq(
    V.nebula_cert_sign.fileglob().first().dirname().toText(),
    "{{ nebula_cert_sign | fileglob | first | dirname }}",
    "chain renders canonical",
  );
});

Deno.test("mapAttr on a register field .ref", () => {
  const find = register("_find");
  eq(
    find.files.ref.mapAttr("path").toText(),
    "{{ _find.files | map(attribute='path') }}",
    "mtail loop",
  );
});

Deno.test("strip + split: python str methods", () => {
  eq(
    V.sshlogin_dst_host_keys.strip().split("\\n").toText(),
    "{{ sshlogin_dst_host_keys.strip().split('\\n') }}",
    "sshlogin host-keys loop",
  );
});

Deno.test("regexReplace: ansible.builtin regex_replace filter", () => {
  const slurp = register("_slurp");
  eq(
    slurp.content.ref.b64decode().regexReplace("[^=]+=(\\S+)\\s*", "\\1")
      .toText(),
    "{{ _slurp.content | b64decode | regex_replace('[^=]+=(\\S+)\\s*', '\\1') }}",
    "password_env_file extract",
  );
});

Deno.test("passwordHash: ansible.builtin password_hash filter", () => {
  // scheme + ref salt (nextcloud_sftp sftp user password)
  eq(
    V.vault_nc_paul_upload_password.passwordHash("sha512", V.vault_pw_salt)
      .toText(),
    "{{ vault_nc_paul_upload_password | password_hash('sha512', vault_pw_salt) }}",
    "password with salt",
  );
  // scheme only (salt omitted)
  eq(
    V.vault_nc_paul_upload_password.passwordHash("sha512").toText(),
    "{{ vault_nc_paul_upload_password | password_hash('sha512') }}",
    "password without salt",
  );
});
