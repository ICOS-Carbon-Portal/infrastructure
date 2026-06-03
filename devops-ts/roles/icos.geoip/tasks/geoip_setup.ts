import {
  register,
  type TaskFile,
  type Tmpl,
  withItemsOver,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _user = register("_user");

export default [
  {
    name: "Create geoip user",
    user: {
      name: V.geoip_user,
      state: "present",
      create_home: false,
      home: V.geoip_home,
    },
    register: _user,
  },
  {
    name: "Create build directory",
    file: {
      path: V.geoip_build_dir,
      state: "directory",
    },
  },
  {
    name: "Create database volume directory",
    file: {
      path: V.geoip_db_dir,
      state: "directory",
      owner: _user.uid.ref,
      group: _user.group.ref,
    },
  },
  {
    ...withItemsOver<{ src: Tmpl; dest: Tmpl }>(
      [
        { src: "README.md", dest: tmpl`${V.geoip_home}/README.md` },
        { src: "Makefile", dest: tmpl`${V.geoip_home}/Makefile` },
        { src: "Dockerfile", dest: tmpl`${V.geoip_build_dir}/Dockerfile` },
        {
          src: "docker-compose.yml",
          dest: tmpl`${V.geoip_home}/docker-compose.yml`,
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
