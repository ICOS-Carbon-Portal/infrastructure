# DevOps

This directory contains our framework to automatically provision (setup /
install software) on our different servers.

The framework is based around Ansible for provisioning and Vagrant/VirtualBox
for testing.

## rdfStore (the RDF store of meta)

The RDF4J store, its files and the SPARQL protocol endpoints are a service of their own,
separate from `cpmeta` (see `docs/rdf-store-split.md` in the `meta` repository). It is
deployed by role `icos.cpmeta_rdfstore`, which `core.yml` runs on `core_host` just before
`icos.cpmeta`, and by `rdfstore.yml` for jar deployment.

This branch deploys the split codebase only: `cpmeta` always talks to a remote store and no
longer has an embedded one, so it needs a `meta` built from the split codebase.

**Deployment of meta is therefore restricted to `test-fs4` for now**, by
`meta_permitted_inventory` in `group_vars/all/core.yml`. Moving another deployment over means
migrating its RDF store first ("Data migration and cutover" in `docs/rdf-store-split.md`), and
changing that setting. `cpmeta.yml` and `rdfstore.yml` refuse to run against a non-permitted
inventory; `core.yml` skips the two meta roles and the meta nginx site there, so the rest of
core (postgis, rdflog, restheart, cpdata, cpauth, doi) can still be deployed as usual.

```sh
ansible-playbook -i test-fs4.inventory -t cpmeta_rdfstore_deploy -e cpmeta_rdfstore_jar_file=... rdfstore.yml
```

meta's `rdfStore` sbt project deploys through the same playbook
(`cpDeployTarget := "cpmeta_rdfstore"`, `cpDeployPlaybook := "rdfstore.yml"`), so
`sbt "project rdfStore" "cpDeploy to <inventory>"` does the same for the inventories listed in
its own `cpDeployPermittedInventories`; use the ansible command above for the others.

Points to keep in mind:

- rdfStore owns the RDF storage directory (`cpmeta_rdfstore_rdfstorage_path`) and runs as its
  own user; `cpmeta` has no access to it and does not create it.
- `cpmeta` reaches rdfStore over loopback (`cpmeta.remoteRdfRepository` in
  `roles/icos.cpmeta/templates/application_production.conf`). It runs a readiness query at
  startup, so `cpmeta.service` is ordered after `cpmeta_rdfstore.service`.
- The public `<meta host>/sparql` is proxied straight to rdfStore by the meta nginx site
  (`roles/icos.cpmeta/templates/cpmeta.conf`). Everything else rdfStore exposes -
  `/internal/sparql`, `/internal/derived/*`, `/admin/read-only` - is unauthenticated and must
  never be reachable from outside the host.
- rdfStore has exactly one configuration template,
  `roles/icos.cpmeta_rdfstore/templates/application_rdfstore.conf`: the `rdfStore` section it
  alone owns, plus `roles/icos.rdf_common/templates/application_shared.conf`, which holds the
  values it shares with `cpmeta` - the `rdflog` database, the DataCite credential and the ENVRI
  hosts - and one further template for the instance-server/graph layout of the deployment
  flavour at hand. `meta_shared_config_files` (`group_vars/all/core.yml`, overridden per
  inventory) picks that shared list, and both services render the same list into their generated
  `application.conf`, so their views cannot drift. Neither service includes templates from the
  other's role.
- Which RDF logs get restored into which named graph, and any partial replay offsets, are derived
  from that shared `cpmeta.instanceServers` configuration, so an instance server added for meta
  is picked up by rdfStore's replay automatically.
- On a fresh (empty) storage directory, rdfStore replays every configured RDF log from the
  `rdflog` database and then stays **read-only** on purpose. Verify the restore and run
  `ansible-playbook -i <inv> -t cpmeta_rdfstore_restart rdfstore.yml` to get a writable,
  indexed store. Seeding from a store snapshot instead is described under "Data migration and
  cutover" in `docs/rdf-store-split.md`.

## Deploying Drupal websites

The Drupal playbook requires a `website` parameter. It can be one website short name, a list of short names, or `all`.

Deploy one website:

```sh
icos play drupal -e "website=ac" -t drupal -DC
```

Equivalent Ansible command:

```sh
ansible-playbook -i production.inventory -t drupal -e "website=ac" drupal.yml
```

Deploy several websites:

```sh
ansible-playbook -i production.inventory -t drupal -e '{"website":["fi","nl"]}' drupal.yml
```

Deploy all websites from `roles/icos.drupal/defaults/main.yml`:

```sh
ansible-playbook -i production.inventory -t drupal -e website=all drupal.yml
```

Nginx and backup tasks are opt-in only:

```sh
ansible-playbook -i production.inventory -t drupal_nginx -e website=all drupal.yml
ansible-playbook -i production.inventory -t drupal_backup drupal.yml
```
