import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { bbclient_home } from "../../../lib/globals.ts";
import {
  bbclient_coldbackup,
  bbclient_timer_content,
} from "../../../lib/paramvars.ts";
import { bbclient_name } from "../../../lib/sharedvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { isDefined } from "../../../lib/vars.ts";

export default [
  {
    name: "Setup local ssh directory",
    tags: "bbclient_ssh",
    import_tasks: "ssh.yml",
    become: true,
    become_user: V.bbclient_user,
  },
  {
    name: "Install bbclient shell-scripts",
    tags: "bbclient_scripts",
    import_tasks: "scripts.yml",
    become: true,
    become_user: V.bbclient_user,
  },
  { import_tasks: "repos.yml", tags: "bbclient_repos" },
  {
    name: "Create patterns.lst",
    copy: {
      dest: V.bbclient_patterns_path,
      content: V.bbclient_patterns,
    },
  },
  {
    import_tasks: "coldbackup.yml",
    become: true,
    become_user: V.bbclient_user,
    tags: "bbclient_coldbackup",
    when: isDefined(bbclient_coldbackup),
  },
  {
    name: "Install bbclient backup script",
    include_role: "name=icos.timer",
    vars: {
      timer_home: tmpl`${bbclient_home}/timer`,
      timer_name: tmpl`bbclient-${bbclient_name}`,
      timer_conf: V.bbclient_timer_conf,
      timer_content: bbclient_timer_content,
    },
    tags: "bbclient_timer",
    when: [isDefined(bbclient_timer_content)],
  },
  { import_tasks: "just.yml", tags: "bbclient_just" },
] satisfies TaskFile;
