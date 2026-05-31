import {
  type TaskFile,
  type Tmpl,
  withItemsOver,
} from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create geoip user",
    user: {
      name: V.geoip_user,
      state: "present",
      create_home: false,
      home: V.geoip_home,
    },
    register: "_user",
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
      owner: expr("_user.uid"),
      group: expr("_user.group"),
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
