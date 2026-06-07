import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  flexextract_docker_build,
  flexextract_src_dir,
} from "../../../lib/paramvars.ts";
import { concat, tmpl } from "../../../lib/template.ts";
import { ne, truthy } from "../../../lib/vars.ts";

export default [
  {
    name: tmpl`Copy ${flexextract_src_dir} directory`,
    tags: "flexextract_sync",
    synchronize: {
      src: tmpl`${flexextract_src_dir}/`,
      dest: tmpl`${V.flexextract_home}/build`,
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
      chdir: V.flexextract_home,
      executable: "/bin/bash",
    },
    register: "_output",
    changed_when: '" ---> Running in " in _output.stdout',
    when: truthy(flexextract_docker_build).default(true),
  },
  {
    name: "Create download directory",
    become: true,
    become_user: "root",
    file: {
      path: V.flexextract_download_host,
      state: "directory",
      owner: V.flexextract_user,
      group: V.flexextract_user,
    },
  },
  {
    name: "Create a link to the download directory in home directory",
    file: {
      dest: tmpl`${V.flexextract_home}/download`,
      src: V.flexextract_download_host,
      state: "link",
    },
    when: ne(
      V.flexextract_download_host,
      concat(V.flexextract_home, "/download"),
    ),
  },
  {
    import_tasks: "script.yml",
    tags: "flexextract_script",
  },
] satisfies TaskFile;
