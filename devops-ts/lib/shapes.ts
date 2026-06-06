// Hand-curated OBJECT SHAPES for variables whose fields the playbooks access
// (`wg_hub_config.name`, `jbuild_registry.url`, ...). The generated registries
// (per-role _ctx Vars, sharedvars.ts) declare names as `unknown`, so a
// shape declared here wins in the context intersection (`unknown & T = T`) and
// `V.x.y` becomes a checked, nested reference (see VarRef in lib/template.ts).
//
// Declare only the fields actually referenced; add fields as conversions need
// them. A field name must not collide with a `Template` member (`parts`,
// `default`, `first`, `at`, ...) — the runtime proxy gives those priority.
export interface VarShapes {
  // icos.wg_hub: per-host wireguard config (group_vars), and the hub's own
  // entry (set_fact from it).
  wg_hub_config: {
    name: string;
    allow_all: string;
    allowed_ips: string;
    reresolve: string;
    peers: string;
    hub: { addr: string; peer: string; port: string };
  };
  wg_hub_self: { addr: string; port: string };

  // icos.jbuild: docker registry credentials (vault).
  jbuild_registry: { url: string; username: string; password: string };

  // icos.restheart (cities): basic-auth credentials (vault).
  city_restheart_basic_auth: { username: string; password: string };

  // icos.users / icos.lxd_guest: user roster.
  user_conf: { create_users: string; remove_users: string };
}
