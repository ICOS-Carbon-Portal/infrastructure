import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl, V } from "../_ctx.ts";

const release = register("release");
const url = register("url");

export default [
  {
    name: "Find the latest release of VictoriaMetrics",
    run_once: true,
    delegate_to: "localhost",
    check_mode: false,
    github_release: {
      user: "VictoriaMetrics",
      repo: "VictoriaMetrics",
      action: "latest_release",
    },
    register: release,
  },
  {
    name: "Download vmagent release",
    get_url: {
      url:
        tmpl`https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/${release.tag.ref}/vmutils-linux-${V.vmagent_arch}-${release.tag.ref}.tar.gz`,
      dest: "/tmp",
    },
    register: url,
  },
  {
    name: "Unarchive vmagent",
    unarchive: {
      src: url.dest.ref,
      dest: V.vmagent_bin,
      remote_src: true,
    },
    diff: false,
    register: "unar",
    notify: "restart vmagent",
  },
] satisfies TaskFile;
