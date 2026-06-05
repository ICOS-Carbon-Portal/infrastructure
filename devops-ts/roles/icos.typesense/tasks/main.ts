import {
  isUndefined,
  loopOver,
  notIn,
  type TaskFile,
  type Tmpl,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Include vars",
    include_vars: "vault.yml",
    tags: [
      "setup",
      "initialize_collection",
      "update_synonyms",
      "update_documents",
      "timer",
    ],
  },
  {
    name: "Set up typesense service",
    block: [
      {
        name: "Create user",
        user: { name: V.typesense_user, state: "present" },
      },
      {
        name: tmpl`Create ${V.typesense_home}/docker/ directory`,
        file: {
          path: tmpl`${V.typesense_home}/docker/`,
          state: "directory",
          recurse: true,
          owner: V.typesense_user,
        },
      },
      {
        name: tmpl`Create ${V.typesense_home}/data/ directory`,
        file: {
          path: tmpl`${V.typesense_home}/data/`,
          state: "directory",
          recurse: true,
          owner: V.typesense_user,
        },
      },
      {
        name: tmpl`Create ${V.typesense_home}/analytics/ directory`,
        file: {
          path: tmpl`${V.typesense_home}/analytics/`,
          state: "directory",
          recurse: true,
          owner: V.typesense_user,
        },
      },
      {
        name: "Copy docker-compose.yml",
        template: {
          src: "docker-compose.yml",
          dest: tmpl`${V.typesense_home}/docker/docker-compose.yml`,
          owner: V.typesense_user,
        },
      },
      {
        name: "(Re)start docker containers",
        "community.docker.docker_compose_v2": {
          project_src: tmpl`${V.typesense_home}/docker`,
          state: "present",
          pull: "always",
        },
      },
      {
        include_role: { name: "icos.nginxsite" },
        vars: {
          nginxsite_name: "typesense",
          nginxsite_file: "typesense-nginx.conf",
          nginxsite_domains: ["typesense.icos-cp.eu"],
        },
      },
    ],
    tags: ["setup"],
  },
  {
    name: "Check that website is defined and valid",
    block: [
      {
        name: "Check if website is defined",
        fail: { msg: "website needs to be defined" },
        when: isUndefined(V.website),
      },
      {
        name: "Check that website is valid",
        fail: { msg: "website provided is not valid" },
        when: notIn(V.website, V.base_urls),
      },
    ],
    tags: [
      "initialize_collection",
      "update_synonyms",
      "update_documents",
      "timer",
    ],
  },
  {
    name: "Create and initialize collection",
    block: [
      {
        name: tmpl`Create ${V.website} directory`,
        file: {
          path: tmpl`${V.typesense_home}/${V.website}/`,
          state: "directory",
          recurse: true,
          owner: V.typesense_user,
        },
      },
      {
        name: tmpl`Copy requirements.txt to ${V.typesense_home}`,
        "ansible.builtin.template": {
          src: "requirements.txt",
          dest: tmpl`${V.typesense_home}/requirements.txt`,
          owner: V.typesense_user,
        },
      },
      {
        name: tmpl`Create log file in ${V.typesense_home}/${V.website}`,
        file: {
          path: tmpl`${V.typesense_home}/${V.website}/collection.log`,
          state: "touch",
          mode: "u+rw,g-wx,o-rwx",
          modification_time: "preserve",
          access_time: "preserve",
          owner: V.typesense_user,
        },
      },
      {
        name: tmpl`Set up logrotate for typesense website ${V.website}`,
        "ansible.builtin.template": {
          src: "logrotate",
          dest: tmpl`/etc/logrotate.d/typesense-${V.website}`,
        },
      },
      loopOver<{ src: Tmpl }>(
        [
          { src: "schema.yml" },
          { src: "init_collection.py" },
          { src: "init_documents.py" },
          { src: "update_documents.py" },
          { src: "update_stations.py" },
          { src: "utilities.py" },
        ],
        (item) => ({
          name: tmpl`Copy python scripts and schema to ${V.website} directory`,
          "ansible.builtin.template": {
            src: item.src,
            dest: tmpl`${V.typesense_home}/${V.website}`,
            owner: V.typesense_user,
          },
        }),
      ),
      {
        name: "Install required modules into Python virtual environment",
        "ansible.builtin.pip": {
          virtualenv: tmpl`${V.typesense_home}/typesense-venv`,
          virtualenv_command: "python3 -m venv",
          requirements: tmpl`${V.typesense_home}/requirements.txt`,
        },
      },
      {
        name: "Create collection",
        "ansible.builtin.shell":
          tmpl`${V.typesense_home}/typesense-venv/bin/python3 ${V.typesense_home}/${V.website}/init_collection.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${V.typesense_home}/${V.website}` },
      },
      {
        name: "Add initial documents to collection",
        "ansible.builtin.shell":
          tmpl`${V.typesense_home}/typesense-venv/bin/python3 ${V.typesense_home}/${V.website}/init_documents.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${V.typesense_home}/${V.website}` },
      },
      {
        name: "Add initial stations to collection",
        "ansible.builtin.shell":
          tmpl`${V.typesense_home}/typesense-venv/bin/python3 ${V.typesense_home}/${V.website}/update_stations.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${V.typesense_home}/${V.website}` },
      },
    ],
    tags: ["initialize_collection"],
  },
  {
    name: "Add timer for updating documents and stations",
    block: [
      {
        name: tmpl`Install typesense-update-${V.website} timer`,
        include_role: { name: "icos.timer" },
        vars: {
          timer_user: V.typesense_user,
          timer_home: V.typesense_home,
          timer_name: tmpl`typesense-update-${V.website}`,
          timer_conf: "OnCalendar=*-*-* 1/4:17:00\n",
          timer_content:
            tmpl`#!/bin/bash\ncd ${V.typesense_home}/${V.website}\n${V.typesense_home}/typesense-venv/bin/python3 update_documents.py >> collection.log 2>&1\n${V.typesense_home}/typesense-venv/bin/python3 update_stations.py >> collection.log 2>&1\n`,
        },
      },
    ],
    tags: ["initialize_collection", "timer"],
  },
  {
    name: "Update synonyms",
    block: [
      loopOver<{ src: Tmpl }>(
        [{ src: "update_synonyms.py" }, { src: "utilities.py" }],
        (item) => ({
          name:
            tmpl`Copy update_synonyms required python scripts to ${V.website} directory`,
          "ansible.builtin.template": {
            src: item.src,
            dest: tmpl`${V.typesense_home}/${V.website}`,
            owner: V.typesense_user,
          },
        }),
      ),
      {
        name: "Run update synonyms script",
        "ansible.builtin.shell":
          tmpl`${V.typesense_home}/typesense-venv/bin/python3 ${V.typesense_home}/${V.website}/update_synonyms.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${V.typesense_home}/${V.website}` },
      },
    ],
    tags: ["update_synonyms", "initialize_collection"],
  },
  {
    name: "Update documents and stations without reinitializing collection",
    block: [
      loopOver<{ src: Tmpl }>(
        [
          { src: "update_documents.py" },
          { src: "update_stations.py" },
          { src: "utilities.py" },
        ],
        (item) => ({
          name: tmpl`Copy python scripts to ${V.website} directory`,
          "ansible.builtin.template": {
            src: item.src,
            dest: tmpl`${V.typesense_home}/${V.website}`,
            owner: V.typesense_user,
          },
        }),
      ),
      {
        name: "Run update documents script",
        "ansible.builtin.shell":
          tmpl`${V.typesense_home}/typesense-venv/bin/python3 ${V.typesense_home}/${V.website}/update_documents.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${V.typesense_home}/${V.website}` },
      },
      {
        name: "Run update stations script",
        "ansible.builtin.shell":
          tmpl`${V.typesense_home}/typesense-venv/bin/python3 ${V.typesense_home}/${V.website}/update_stations.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${V.typesense_home}/${V.website}` },
      },
    ],
    tags: ["update_documents"],
  },
] satisfies TaskFile;
