import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create mailman certificate",
    include_role: { name: "icos.certbot2", public: true },
    vars: {
      certbot_name: "{{ mailman_certbot_name }}",
      certbot_domains: "{{ mailman_domains }}",
    },
  },
  {
    name: "Create mailmain nginx config",
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: "{{ mailman_nginxsite_name }}",
      nginxsite_file: "{{ mailman_nginxsite_file }}",
    },
  },
] satisfies TaskFile;
