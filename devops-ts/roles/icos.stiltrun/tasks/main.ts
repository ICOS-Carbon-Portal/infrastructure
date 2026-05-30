import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "List docker images matching the stiltrun image",
    command: "docker images -qa {{stiltrun_image_name}}",
    register: "docker_images",
    changed_when: false,
  },
  {
    when: raw("stiltrun_image_id not in docker_images.stdout"),
    become: '{{ stiltrun_user != "root" }}',
    become_user: V.stiltrun_user,
    block: [
      {
        name: "Download stilt docker image",
        get_url: {
          url: V.stiltrun_image_url,
          dest: "/tmp",
        },
        register: "_get_url",
      },
      {
        name: "Load stilt image into docker",
        command: 'docker load -i "{{ _get_url.dest }}"',
        changed_when: false,
      },
      {
        name: "Check that stiltrun_image was properly loaded",
        shell: tmpl`docker images -q | grep ${V.stiltrun_image_id} -q`,
        changed_when: false,
      },
      {
        name: "Tag the stiltrun image",
        shell: "docker tag {{stiltrun_image_id}} {{stiltrun_image_name}}",
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
    register: "_stilt_py",
  },
  {
    name: "Test stiltrun by running listmetfiles",
    command: "{{ _stilt_py.dest }} listmetfiles",
    changed_when: false,
  },
  {
    name: "Test stiltrun by running calcslots",
    command: "{{ _stilt_py.dest }} calcslots 2012010100 2012010106",
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
