import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Build and deploy docker images",
    import_tasks: "docker.yml",
    tags: "nexus_docker",
  },
  {
    name: "Create certificate and create nginx config",
    import_tasks: "nginx.yml",
    tags: "nexus_nginx",
  },
] satisfies TaskFile;
