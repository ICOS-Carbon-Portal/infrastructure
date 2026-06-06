import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { or } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

const _compose = register("_compose");
const _dockerfile = register("_dockerfile");
const _jarfile = register("_jarfile");
const _config = register("_config");

export default [
  // https://fairdatapoint.readthedocs.io
  {
    name: "Create fairdatapoint directory",
    file: {
      path: tmpl`${V.fdp_home}/`,
      state: "directory",
    },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: V.fdp_home,
      lstrip_blocks: true,
    },
    register: _compose,
  },
  {
    name: "Copy Dockerfile",
    template: {
      src: "Dockerfile",
      dest: V.fdp_home,
    },
    register: _dockerfile,
  },
  // either get a copy of the jar in production or package the FAIRDataPoint project anew (https://github.com/ICOS-Carbon-Portal/FAIRDataPoint)
  {
    name: "Copy jarfile",
    copy: {
      src: V.fdp_jar_file,
      dest: tmpl`${V.fdp_home}/fdp.jar`,
    },
    register: _jarfile,
  },
  {
    name: "Copy application.yml",
    template: {
      src: "application.yml",
      dest: tmpl`${V.fdp_home}/`,
      lstrip_blocks: true,
    },
    register: _config,
  },
  {
    name: "Copy files",
    copy: {
      dest: V.fdp_home,
      src: V.item,
    },
    loop: ["eh-next_logo.png", "_variables.scss"],
  },
  {
    name: "Start fairdatapoint",
    icos_docker_compose: {
      chdir: V.fdp_home,
      force_recreate: or(
        _config.changed,
        _compose.changed,
        _jarfile.changed,
        _dockerfile.changed,
      ).asValue(),
    },
  },
] satisfies TaskFile;
