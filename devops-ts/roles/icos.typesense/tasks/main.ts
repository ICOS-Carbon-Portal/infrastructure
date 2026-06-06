import { base_urls, typesense_home, typesense_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOver } from "../../../lib/loop.ts";
import { website } from "../../../lib/paramvars.ts";
import { type Tmpl, tmpl } from "../../../lib/template.ts";
import { isUndefined, notIn } from "../../../lib/vars.ts";

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
        user: { name: typesense_user, state: "present" },
      },
      {
        name: tmpl`Create ${typesense_home}/docker/ directory`,
        file: {
          path: tmpl`${typesense_home}/docker/`,
          state: "directory",
          recurse: true,
          owner: typesense_user,
        },
      },
      {
        name: tmpl`Create ${typesense_home}/data/ directory`,
        file: {
          path: tmpl`${typesense_home}/data/`,
          state: "directory",
          recurse: true,
          owner: typesense_user,
        },
      },
      {
        name: tmpl`Create ${typesense_home}/analytics/ directory`,
        file: {
          path: tmpl`${typesense_home}/analytics/`,
          state: "directory",
          recurse: true,
          owner: typesense_user,
        },
      },
      {
        name: "Copy docker-compose.yml",
        template: {
          src: "docker-compose.yml",
          dest: tmpl`${typesense_home}/docker/docker-compose.yml`,
          owner: typesense_user,
        },
      },
      {
        name: "(Re)start docker containers",
        "community.docker.docker_compose_v2": {
          project_src: tmpl`${typesense_home}/docker`,
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
        when: isUndefined(website),
      },
      {
        name: "Check that website is valid",
        fail: { msg: "website provided is not valid" },
        when: notIn(website, base_urls),
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
        name: tmpl`Create ${website} directory`,
        file: {
          path: tmpl`${typesense_home}/${website}/`,
          state: "directory",
          recurse: true,
          owner: typesense_user,
        },
      },
      {
        name: tmpl`Copy requirements.txt to ${typesense_home}`,
        "ansible.builtin.template": {
          src: "requirements.txt",
          dest: tmpl`${typesense_home}/requirements.txt`,
          owner: typesense_user,
        },
      },
      {
        name: tmpl`Create log file in ${typesense_home}/${website}`,
        file: {
          path: tmpl`${typesense_home}/${website}/collection.log`,
          state: "touch",
          mode: "u+rw,g-wx,o-rwx",
          modification_time: "preserve",
          access_time: "preserve",
          owner: typesense_user,
        },
      },
      {
        name: tmpl`Set up logrotate for typesense website ${website}`,
        "ansible.builtin.template": {
          src: "logrotate",
          dest: tmpl`/etc/logrotate.d/typesense-${website}`,
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
          name: tmpl`Copy python scripts and schema to ${website} directory`,
          "ansible.builtin.template": {
            src: item.src,
            dest: tmpl`${typesense_home}/${website}`,
            owner: typesense_user,
          },
        }),
      ),
      {
        name: "Install required modules into Python virtual environment",
        "ansible.builtin.pip": {
          virtualenv: tmpl`${typesense_home}/typesense-venv`,
          virtualenv_command: "python3 -m venv",
          requirements: tmpl`${typesense_home}/requirements.txt`,
        },
      },
      {
        name: "Create collection",
        "ansible.builtin.shell":
          tmpl`${typesense_home}/typesense-venv/bin/python3 ${typesense_home}/${website}/init_collection.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${typesense_home}/${website}` },
      },
      {
        name: "Add initial documents to collection",
        "ansible.builtin.shell":
          tmpl`${typesense_home}/typesense-venv/bin/python3 ${typesense_home}/${website}/init_documents.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${typesense_home}/${website}` },
      },
      {
        name: "Add initial stations to collection",
        "ansible.builtin.shell":
          tmpl`${typesense_home}/typesense-venv/bin/python3 ${typesense_home}/${website}/update_stations.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${typesense_home}/${website}` },
      },
    ],
    tags: ["initialize_collection"],
  },
  {
    name: "Add timer for updating documents and stations",
    block: [
      {
        name: tmpl`Install typesense-update-${website} timer`,
        include_role: { name: "icos.timer" },
        vars: {
          timer_user: typesense_user,
          timer_home: typesense_home,
          timer_name: tmpl`typesense-update-${website}`,
          timer_conf: "OnCalendar=*-*-* 1/4:17:00\n",
          timer_content:
            tmpl`#!/bin/bash\ncd ${typesense_home}/${website}\n${typesense_home}/typesense-venv/bin/python3 update_documents.py >> collection.log 2>&1\n${typesense_home}/typesense-venv/bin/python3 update_stations.py >> collection.log 2>&1\n`,
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
            tmpl`Copy update_synonyms required python scripts to ${website} directory`,
          "ansible.builtin.template": {
            src: item.src,
            dest: tmpl`${typesense_home}/${website}`,
            owner: typesense_user,
          },
        }),
      ),
      {
        name: "Run update synonyms script",
        "ansible.builtin.shell":
          tmpl`${typesense_home}/typesense-venv/bin/python3 ${typesense_home}/${website}/update_synonyms.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${typesense_home}/${website}` },
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
          name: tmpl`Copy python scripts to ${website} directory`,
          "ansible.builtin.template": {
            src: item.src,
            dest: tmpl`${typesense_home}/${website}`,
            owner: typesense_user,
          },
        }),
      ),
      {
        name: "Run update documents script",
        "ansible.builtin.shell":
          tmpl`${typesense_home}/typesense-venv/bin/python3 ${typesense_home}/${website}/update_documents.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${typesense_home}/${website}` },
      },
      {
        name: "Run update stations script",
        "ansible.builtin.shell":
          tmpl`${typesense_home}/typesense-venv/bin/python3 ${typesense_home}/${website}/update_stations.py >> collection.log 2>&1\n`,
        args: { chdir: tmpl`${typesense_home}/${website}` },
      },
    ],
    tags: ["update_documents"],
  },
] satisfies TaskFile;
