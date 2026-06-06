// icos play cpdata cpdata_deploy -ecpdata_jar_file=/tmp/cpdata.jar
// icos play cpdata cpdata_config
//
// Everything that mentions "netcdf" has to do with https://data.icos-cp.eu/netcdf/
import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";
import { V } from "../lib/vars.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.certbot2", {
        certbot_name: V.cpdata_cert_name,
        certbot_domains: V.cpdata_domains,
      }).tags("cert"),

      role("icos.nginxsite", {
        nginxsite_name: "cpdata",
        nginxsite_file: "roles/icos.cpdata/templates/cpdata.conf",
      }).tags("nginx"),

      role("icos.cpdata", {
        cpdata_netcdf_folder: "/disk/data/common/netcdf/dataDemo",
      }).tags("cpdata"),

      role("icos.dataold").tags("dataold"),
    ],
  },
] satisfies Playbook;
