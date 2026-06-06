import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { loopOverVar } from "../../../lib/loop.ts";
import { user_conf } from "../../../lib/shapes.ts";
import { tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  loopOverVar<{ groups: string; home: string; name: string; password: string }>(
    user_conf.create_users.default([]),
    (item) => ({
      name: "Create user",
      user: {
        name: item.name,
        password: item.password.default(omit),
        home: item.home.default(omit),
        groups: item.groups.default(omit),
        append: item.groups.default(false).bool(),
      },
    }),
  ),
  loopOverVar<{ key: string; name: string }>(
    user_conf.create_users.default([]),
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
    user_conf.create_users.default([]),
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
    user_conf.remove_users.default([]),
    (item) => ({
      name: "Remove user",
      user: {
        name: item.name,
        remove: item.remove.default(omit),
        state: "absent",
      },
    }),
  ),
] satisfies TaskFile;
