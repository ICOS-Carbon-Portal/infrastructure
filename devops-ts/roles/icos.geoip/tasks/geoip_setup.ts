import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create geoip user",
    user: {
      name: "{{ geoip_user }}",
      state: "present",
      create_home: false,
      home: "{{ geoip_home }}",
    },
    register: "_user",
  },
  {
    name: "Create build directory",
    file: {
      path: "{{ geoip_build_dir }}",
      state: "directory",
    },
  },
  {
    name: "Create database volume directory",
    file: {
      path: "{{ geoip_db_dir }}",
      state: "directory",
      owner: "{{ _user.uid }}",
      group: "{{ _user.group }}",
    },
  },
  {
    name: "Install files",
    template: {
      src: "{{ item.src }}",
      dest: "{{ item.dest }}",
    },
    with_items: [
      { src: "README.md", dest: "{{ geoip_home }}/README.md" },
      { src: "Makefile", dest: "{{ geoip_home }}/Makefile" },
      { src: "Dockerfile", dest: "{{ geoip_build_dir }}/Dockerfile" },
      {
        src: "docker-compose.yml",
        dest: "{{ geoip_home }}/docker-compose.yml",
      },
    ],
  },
] satisfies TaskFile;
