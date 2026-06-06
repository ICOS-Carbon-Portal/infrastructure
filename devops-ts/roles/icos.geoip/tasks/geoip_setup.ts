import {
  geoip_build_dir,
  geoip_db_dir,
  geoip_home,
  geoip_user,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { withItemsOver } from "../../../lib/loop.ts";
import { register } from "../../../lib/register.ts";
import { type Tmpl, tmpl } from "../../../lib/template.ts";

const _user = register("_user");

export default [
  {
    name: "Create geoip user",
    user: {
      name: geoip_user,
      state: "present",
      create_home: false,
      home: geoip_home,
    },
    register: _user,
  },
  {
    name: "Create build directory",
    file: {
      path: geoip_build_dir,
      state: "directory",
    },
  },
  {
    name: "Create database volume directory",
    file: {
      path: geoip_db_dir,
      state: "directory",
      owner: _user.uid.ref,
      group: _user.group.ref,
    },
  },
  {
    ...withItemsOver<{ src: Tmpl; dest: Tmpl }>(
      [
        { src: "README.md", dest: tmpl`${geoip_home}/README.md` },
        { src: "Makefile", dest: tmpl`${geoip_home}/Makefile` },
        { src: "Dockerfile", dest: tmpl`${geoip_build_dir}/Dockerfile` },
        {
          src: "docker-compose.yml",
          dest: tmpl`${geoip_home}/docker-compose.yml`,
        },
      ],
      (item) => ({
        name: "Install files",
        template: {
          src: item.src,
          dest: item.dest,
        },
      }),
    ),
  },
] satisfies TaskFile;
