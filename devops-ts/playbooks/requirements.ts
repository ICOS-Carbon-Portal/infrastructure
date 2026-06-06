// NOTE: This is an Ansible Galaxy requirements file, NOT a playbook. It renders
// to a top-level YAML *mapping* (`collections: [...]`), whereas the renderer in
// lib/ansible/render.ts only emits a top-level *sequence* of plays. The data below is
// faithful to ../devops/requirements.yml, but `render()` cannot currently emit a
// mapping (its `for (const play of clean)` loop requires an array), so this file
// cannot be made to verify OK without a renderer change. See NOTES in the report.

export default {
  collections: [
    { name: "community.general", version: ">=9.0.0" },
    { name: "ansible.posix" },
    { name: "community.docker" },
    { name: "community.mysql" },
    { name: "community.postgresql" },
    { name: "community.crypto" },
  ],
};
