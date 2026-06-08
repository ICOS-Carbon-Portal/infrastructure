// NOTE: This is an Ansible Galaxy requirements file, NOT a playbook. It renders
// to a top-level YAML *mapping* (`collections: [...]`) rather than a sequence of
// plays, so it can't use the typed `playbook()` wrapper. It self-renders via the
// same underlying `renderToStdout` helper instead.
import { renderToStdout } from "../lib/ansible/playbook.ts";

const requirements = {
  collections: [
    { name: "community.general", version: ">=9.0.0" },
    { name: "ansible.posix" },
    { name: "community.docker" },
    { name: "community.mysql" },
    { name: "community.postgresql" },
    { name: "community.crypto" },
  ],
};

renderToStdout(import.meta, requirements);

export default requirements;
