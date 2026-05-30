import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Copy {{ flexextract_src_dir }} directory",
    tags: "flexextract_sync",
    synchronize: {
      src: "{{ flexextract_src_dir }}/",
      dest: "{{ flexextract_home }}/build",
    },
  },
  {
    name: "Build flexextract image",
    tags: "flexextract_build",
    shell: `set -o pipefail
( echo -n '=== starting build '; date; \\
  docker build -t {{ flexextract_tag }} build --pull) \\
| tee -a build.log
`,
    args: {
      chdir: "{{ flexextract_home }}",
      executable: "/bin/bash",
    },
    register: "_output",
    changed_when: '" ---> Running in " in _output.stdout',
    when: raw("flexextract_docker_build | default(True)"),
  },
  {
    name: "Create download directory",
    become: true,
    become_user: "root",
    file: {
      path: "{{ flexextract_download_host }}",
      state: "directory",
      owner: "{{ flexextract_user }}",
      group: "{{ flexextract_user }}",
    },
  },
  {
    name: "Create a link to the download directory in home directory",
    file: {
      dest: "{{ flexextract_home }}/download",
      src: "{{ flexextract_download_host }}",
      state: "link",
    },
    when: raw('flexextract_download_host  != (flexextract_home+"/download")'),
  },
  {
    import_tasks: "script.yml",
    tags: "flexextract_script",
  },
] satisfies TaskFile;
