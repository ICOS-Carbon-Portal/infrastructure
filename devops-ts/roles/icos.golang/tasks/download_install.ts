import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl, V } from "../_ctx.ts";

const _download = register("_download");

export default [
  // https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04

  // Never overwrite apt-installed go with downloaded version.
  {
    name: "Fail if golang-go is apt-installed",
    "ansible.builtin.shell":
      `dpkg --get-selections golang-go | grep -vq '\\binstall'
`,
    changed_when: false,
    register: "r",
    failed_when: "r.rc == 0",
  },
  {
    name: "We only support amd64 for now",
    assert: {
      that: 'ansible_machine == "x86_64"',
    },
    changed_when: false,
  },
  {
    name: "Download go binary",
    get_url: {
      url: V.golang_url,
      dest: "/tmp",
    },
    register: _download,
  },
  {
    name: "Create golang directory",
    file: {
      path: V.golang_opt_dir,
      state: "directory",
    },
  },
  {
    name: "Unarchive golang",
    unarchive: {
      src: _download.dest.ref,
      dest: V.golang_opt_dir,
      remote_src: true,
    },
    diff: false,
  },
  {
    name: "Create symlinks for go binaries",
    file: {
      dest: tmpl`/usr/local/bin/${V.item}`,
      src: tmpl`${V.golang_bin_dir}/${V.item}`,
      state: "link",
    },
    loop: ["go", "gofmt"],
  },
] satisfies TaskFile;
