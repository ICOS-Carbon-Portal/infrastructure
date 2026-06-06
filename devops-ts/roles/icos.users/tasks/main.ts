import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOverVar } from "../../../lib/loop.ts";
import { truthy } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  loopOverVar<{ groups: string; home: string; name: string; password: string }>(
    V.user_conf.create_users.default([]),
    (item) => ({
      name: "Create user",
      user: {
        name: item.name,
        password: item.password.default(V.omit),
        home: item.home.default(V.omit),
        groups: item.groups.default(V.omit),
        append: item.groups.default(false).bool(),
      },
    }),
  ),
  loopOverVar<{ key: string; name: string }>(
    V.user_conf.create_users.default([]),
    (item) => ({
      name: "Install public key",
      authorized_key: {
        user: item.name,
        key: item.key,
        state: "present",
        exclusive: true,
      },
    }),
  ),
  loopOverVar<{ name: string; sudopwless: boolean }>(
    V.user_conf.create_users.default([]),
    (item) => ({
      name: "Install password-less sudo rule",
      copy: {
        dest: tmpl`/etc/sudoers.d/${item.name}`,
        content: `{{ item.name }} ALL=(ALL) NOPASSWD: ALL
`,
      },
      when: truthy(item.sudopwless.default(false)),
    }),
  ),
  loopOverVar<{ name: string; remove: string }>(
    V.user_conf.remove_users.default([]),
    (item) => ({
      name: "Remove user",
      user: {
        name: item.name,
        remove: item.remove.default(V.omit),
        state: "absent",
      },
    }),
  ),
] satisfies TaskFile;
