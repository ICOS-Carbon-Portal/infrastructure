import {
  loopOver,
  raw,
  register,
  type TaskFile,
} from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

const _export = register("_export");

export default [
  // Create a user which is used 1) to compile the docker image 2) to allow remote
  // access to those holding its private key.
  {
    name: "Create flexpart user",
    user: {
      name: V.flexpart_user,
      state: "present",
      groups: "docker",
      append: true,
    },
    register: "_user",
  },
  {
    name: "Create the flexpart output directory",
    file: {
      path: V.flexpart_output_directory,
      state: "directory",
    },
  },
  {
    become: true,
    become_user: V.flexpart_user,
    block: [
      {
        name: "Create flexpart build dir",
        file: {
          path: "{{ _user.home }}/build",
          state: "directory",
        },
        register: "_build",
      },
      // This script is the only command that can be run by remote users using the
      // flexpart private key.
      {
        name: "Install the flexpart ssh script",
        copy: {
          src: "flexpart_ssh.sh",
          dest: "{{ _user.home }}/flexpart_ssh.sh",
          mode: 0o755,
        },
      },
      {
        name: "Authorize our own ssh key",
        authorized_key: {
          user: V.flexpart_user,
          state: "present",
          key: "{{ lookup('file', 'roles/icos.flexpart/files/flexpart.pub') }}",
          key_options: 'command="{{ _user.home }}/flexpart_ssh.sh"',
        },
      },
      {
        name: "Install Dockerfile and build resources",
        copy: {
          src: V.item,
          dest: "{{ _build.path }}",
        },
        loop: [
          "Dockerfile",
          // At this point the flexpart10.2.tar.gz is no longer available from the
          // flexpart project homepage, so we ship our own version.
          "flexpart10.2.tar.gz",
          // The source code for a small utility program to be run before the
          // invocation of flexpart.
          "flextraset.lpr",
          // Our modifications to flexpart source code.
          "flexpart.diff",
          "entrypoint.sh",
          "candidate_sites.txt",
          // More franken-files needed to run flexpart
          "grib_api.tgz",
          "options.tgz",
        ],
        register: "_resources",
      },
      {
        name: "Build flexpart image",
        docker_image: {
          source: "build",
          name: V.flexpart_image,
          build: {
            path: "{{ _build.path }}",
          },
        },
      },
    ],
  },
  loopOver<{ dest: string; src: string }>(
    [
      { src: "flexpart.sh.j2", dest: "/usr/local/bin/flexpart" },
      { src: "flexpart_run.sh.j2", dest: "/usr/local/bin/flexpart_run" },
    ],
    (item) => ({
      name: "Install the flexpart shell scripts",
      template: {
        src: item.src,
        dest: item.dest,
        mode: 0o755,
      },
    }),
  ),
  {
    when: raw('flexpart_export_output_to != ""'),
    block: [
      {
        name: "Install ssh server",
        apt: {
          name: "nfs-kernel-server",
          state: "present",
        },
      },
      {
        name: "Export flexpart output data via nfs",
        blockinfile: {
          marker: "# {mark} ansible/flexpart",
          create: true,
          path: "/etc/exports",
          block:
            `{{ flexpart_output_directory }} {{ flexpart_export_output_to }}
`,
        },
        register: _export,
      },
      {
        name: "Re-export filesystems",
        command: "/usr/sbin/exportfs -ra",
        when: _export.changed,
      },
    ],
  },
] satisfies TaskFile;
