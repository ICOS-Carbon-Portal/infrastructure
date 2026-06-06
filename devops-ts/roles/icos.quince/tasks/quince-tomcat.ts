import { quince_tomcat_home, quince_tomcat_url, quince_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { quince_tomcat_dir } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { jinja, tmpl } from "../../../lib/template.ts";

const _fs = register("_fs");

export default [
  {
    name: "Download tomcat binary",
    get_url: {
      url: quince_tomcat_url,
      dest: "/opt/tomcat.tgz",
    },
  },
  {
    name: "Unarchive /opt/tomcat.tgz",
    unarchive: {
      src: "/opt/tomcat.tgz",
      dest: "/opt",
      remote_src: true,
      owner: quince_user,
      group: quince_user,
    },
    diff: false,
  },
  {
    name: "Find the unpackad tomcat directory",
    find: {
      file_type: "directory",
      recurse: false,
      paths: "/opt",
      patterns: "apache-tomcat-*",
    },
    register: _fs,
  },
  {
    name: "Extract the version-specific directory of tomcat",
    set_fact: {
      quince_tomcat_dir:
        jinja`{{ (${_fs.files.ref} | sort(attribute='path') | last).path  }}`,
    },
  },
  {
    name: "Create /opt/tomcat symlink",
    file: {
      dest: quince_tomcat_home,
      src: quince_tomcat_dir,
      state: "link",
    },
  },
  {
    name: "Create /usr/bin/catalina.sh symlink",
    file: {
      dest: "/usr/bin/catalina.sh",
      src: tmpl`${quince_tomcat_home}/bin/catalina.sh`,
      state: "link",
    },
  },
  {
    name: "Copy quince.service",
    template: {
      src: "quince.service",
      dest: "/etc/systemd/system/quince.service",
    },
    notify: "reload systemd config",
  },
  {
    name: "Enable QuinCe service",
    service: {
      name: "quince",
      state: "started",
      enabled: true,
    },
  },
] satisfies TaskFile;
