import {
  certbot_domains,
  geoip_git_repo,
  geoip_git_version,
  geoip_home,
  geoip_repo_dir,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { geoip_docker_build } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { not, truthy } from "../../../lib/vars.ts";

const r = register("r");

export default [
  {
    name: "Pull source",
    git: {
      repo: geoip_git_repo,
      version: geoip_git_version,
      dest: geoip_repo_dir,
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
      chdir: geoip_home,
      executable: "/bin/bash",
    },
    register: "_output",
    changed_when: '" ---> Running in " in _output.stdout',
    when: truthy(geoip_docker_build).default(true),
  },
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": {
      project_src: geoip_home,
    },
  },
  {
    name: "Check that geoip responds",
    uri: {
      url: tmpl`http://${certbot_domains.first()}:/ip/8.8.8.8`,
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
