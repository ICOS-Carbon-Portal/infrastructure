import { not, raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const r = register("r");

export default [
  {
    name: "Pull source",
    git: {
      repo: V.geoip_git_repo,
      version: V.geoip_git_version,
      dest: V.geoip_repo_dir,
      force: true,
    },
    register: "_git",
  },
  {
    name: "Build geoip images using docker-compose",
    shell: `set -o pipefail
( echo -n '=== starting build '; date; docker-compose build --pull) \\
| tee -a build.log
`,
    args: {
      chdir: V.geoip_home,
      executable: "/bin/bash",
    },
    register: "_output",
    changed_when: '" ---> Running in " in _output.stdout',
    when: raw("geoip_docker_build | default(True)"),
  },
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": {
      project_src: V.geoip_home,
    },
  },
  {
    name: "Check that geoip responds",
    uri: {
      url: tmpl`http://${V.certbot_domains.first()}:/ip/8.8.8.8`,
      return_content: true,
    },
    register: r,
    failed_when: "r.failed or r.json | json_query('ip') != '8.8.8.8'",
    retries: 2,
    delay: 10,
    until: not(r.failed),
    tags: "geoip_check",
  },
] satisfies TaskFile;
