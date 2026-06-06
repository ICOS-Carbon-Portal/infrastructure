import { ne, notIn, register, type TaskFile } from "../../../lib/ansible.ts";
import { rawTmpl, tmpl, V } from "../_ctx.ts";

const _get_url = register("_get_url");
const _stilt_py = register("_stilt_py");
const docker_images = register("docker_images");

export default [
  {
    name: "List docker images matching the stiltrun image",
    command: tmpl`docker images -qa ${rawTmpl("{{stiltrun_image_name}}")}`,
    register: docker_images,
    changed_when: false,
  },
  {
    when: notIn(V.stiltrun_image_id, docker_images.stdout),
    become: ne(V.stiltrun_user, "root").asValue(),
    become_user: V.stiltrun_user,
    block: [
      {
        name: "Download stilt docker image",
        get_url: {
          url: V.stiltrun_image_url,
          dest: "/tmp",
        },
        register: _get_url,
      },
      {
        name: "Load stilt image into docker",
        command: tmpl`docker load -i "${_get_url.dest.ref}"`,
        changed_when: false,
      },
      {
        name: "Check that stiltrun_image was properly loaded",
        shell: tmpl`docker images -q | grep ${V.stiltrun_image_id} -q`,
        changed_when: false,
      },
      {
        name: "Tag the stiltrun image",
        shell: tmpl`docker tag ${rawTmpl("{{stiltrun_image_id}}")} ${
          rawTmpl("{{stiltrun_image_name}}")
        }`,
        changed_when: false,
      },
    ],
  },
  {
    name: "Install the stilt python wrapper",
    template: {
      src: "stilt.py",
      dest: "/usr/local/bin/stilt",
      mode: 0o755,
    },
    register: _stilt_py,
  },
  {
    name: "Test stiltrun by running listmetfiles",
    command: tmpl`${_stilt_py.dest.ref} listmetfiles`,
    changed_when: false,
  },
  {
    name: "Test stiltrun by running calcslots",
    command: tmpl`${_stilt_py.dest.ref} calcslots 2012010100 2012010106`,
    register: "stilt_output",
    changed_when: false,
    failed_when: false,
  },
  {
    name: "Check the output of calcslots",
    assert: {
      that: 'stilt_output.stdout == "2012010100\\n2012010103\\n2012010106"',
    },
    changed_when: false,
  },
] satisfies TaskFile;
