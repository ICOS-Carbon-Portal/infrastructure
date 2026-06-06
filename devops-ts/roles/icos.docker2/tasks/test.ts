import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Test that docker can pull and execute images",
    shell: `docker run --rm alpine apk | grep -q coffee
`,
    register: "_apk",
    changed_when: false,
  },
  {
    name: "Report docker status",
    debug: {
      msg: `Successfully ran an alpine image in {{ _apk.delta }}. It should take
1-10 seconds, depending on whether the alpine image exists locally or
not
`,
    },
  },
] satisfies TaskFile;
