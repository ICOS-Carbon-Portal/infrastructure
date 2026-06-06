import { type TaskFile } from "../../../lib/ansible/play.ts";
import { pct } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

// We use postgres's own apt repo in order to install postgres.
// Debian/Ubuntu then allows multiple installed versions/clusters of postgresql,
// so we try to do the right thing.

export default [
  {
    name: "Adding the apt key for postgresql",
    apt_key: {
      id: "ACCC4CF8",
      url: "https://www.postgresql.org/media/keys/ACCC4CF8.asc",
      state: "present",
    },
  },
  {
    name: "Adding the postgresql repo",
    apt_repository: {
      repo:
        tmpl`deb http://apt.postgresql.org/pub/repos/apt/ ${V.ansible_distribution_release}-pgdg main`,
      filename: "pgdg",
    },
  },
  {
    name: "Install postgresql",
    apt: {
      name: pct("postgresql-%s", V.postgresql_version),
    },
  },
  {
    name: "Install postgis",
    apt: {
      name: pct("postgresql-%s-postgis-3", V.postgresql_version),
    },
    when: truthy(V.postgresql_postgis_enable),
  },
  // Needed for ansible's postgresql_* modules
  {
    name: "Install python3 psycopg2-binary library",
    pip: {
      name: "psycopg2-binary",
      state: "present",
    },
  },
  // We'll keep various scripts in $HOME/bin
  {
    name: tmpl`Create ${V.postgresql_bin} directory`,
    file: {
      path: V.postgresql_bin,
      state: "directory",
      owner: "postgres",
      group: "postgres",
    },
  },
  {
    name: "Modify ~/.profile",
    lineinfile: {
      owner: "postgres",
      group: "postgres",
      create: true,
      path: tmpl`${V.postgresql_home}/.profile`,
      regex: "^PATH=",
      line: "PATH=$HOME/bin:$PATH",
      state: "present",
    },
  },
] satisfies TaskFile;
