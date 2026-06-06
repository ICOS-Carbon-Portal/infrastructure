import { onlyoffice_domain, onlyoffice_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Copy build directory",
    copy: {
      dest: tmpl`${onlyoffice_home}/`,
      src: "build",
    },
  },
  {
    name: "Install runtime environment file",
    copy: {
      mode: "o-r",
      dest: tmpl`${onlyoffice_home}/onlyoffice.env`,
      content: `# JWT == JSON Web Tokens. This is how Nextcloud authenticates
# itself to OnlyOffice.
JWT_ENABLED=true
JWT_SECRET={{ onlyoffice_secret | mandatory }}

# Setting this to false will make the documentserver's entrypoint
# script allow unauthorized HTTPS connections. Use only for testing.
JWT_REJECT_UNAUTHORIZED=true
`,
    },
  },
  // https://helpcenter.onlyoffice.com/installation/docs-enterprise-install-docker.aspx#Registering
  {
    name: "Copy license.lic",
    copy: {
      src: "license.lic",
      dest: tmpl`${onlyoffice_home}/volumes/data/`,
    },
  },
  {
    name: "Copy docker-compose.yml",
    copy: {
      src: "docker-compose.yml",
      dest: onlyoffice_home,
    },
  },
  {
    name: "Install parsetime environment file",
    copy: {
      dest: tmpl`${onlyoffice_home}/.env`,
      content: `ONLYOFFICE_PORT={{ onlyoffice_port }}
ONLYOFFICE_VERSION={{ onlyoffice_version }}
`,
    },
  },
  {
    name: "Build and start",
    "community.docker.docker_compose_v2": {
      project_src: onlyoffice_home,
      build: "always",
    },
  },
  {
    name: "Check that onlyoffice responds - might take a while",
    uri: {
      url: tmpl`https://${onlyoffice_domain}`,
    },
    retries: 60,
    delay: 10,
    changed_when: false,
  },
] satisfies TaskFile;
