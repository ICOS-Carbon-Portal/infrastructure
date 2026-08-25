# DevOps

This directory contains our framework to automatically provision (setup /
install software) on our different servers.

The framework is based around Ansible for provisioning and Vagrant/VirtualBox
for testing.

## rdfStore (the RDF store of meta)

The RDF4J store, its files and the SPARQL protocol endpoints are a service of their own,
separate from `cpmeta` (see `docs/rdf-store-split.md` in the `meta` repository). It is
deployed by role `icos.cpmetardfstore`, which `core.yml` runs on `core_host` just before
`icos.cpmeta`, and by `rdfstore.yml` for jar deployment.

This branch deploys the split codebase only: `cpmeta` always talks to a remote store and no
longer has an embedded one, so every inventory needs a `meta` built from the split codebase.

```sh
ansible-playbook -i <inventory> -t cpmetardfstore_deploy -e cpmetardfstore_jar_file=... rdfstore.yml
```

meta's `rdfStore` sbt project deploys through the same playbook
(`cpDeployTarget := "cpmetardfstore"`, `cpDeployPlaybook := "rdfstore.yml"`), so
`sbt "project rdfStore" "cpDeploy to <inventory>"` does the same, for the inventories listed in
its `cpDeployPermittedInventories`; use the ansible command above for the others.

Points to keep in mind:

- rdfStore owns the RDF storage directory (`cpmetardfstore_rdfstorage_path`) and runs as its
  own user; `cpmeta` has no access to it and does not create it.
- `cpmeta` reaches rdfStore over loopback (`cpmeta.remoteRdfRepository` in
  `roles/icos.cpmeta/templates/application_production.conf`). It runs a readiness query at
  startup, so `cpmeta.service` is ordered after `cpmetardfstore.service`.
- The public `<meta host>/sparql` is proxied straight to rdfStore by the meta nginx site
  (`roles/icos.cpmeta/templates/cpmeta.conf`). Everything else rdfStore exposes -
  `/internal/sparql`, `/internal/derived/*`, `/admin/read-only` - is unauthenticated and must
  never be reachable from outside the host.
- Which RDF logs get restored into which named graph is `rdfStore.rdfLogs`, and it is rdfStore's
  config, not meta's. The application's own defaults cover ICOS and SITES; test-fs4 also serves
  ICOS Cities and adds those logs through `application_rdfstore_staging_amendment.conf`, which
  has to be kept in sync with the instance servers in cpmeta's config. The cities inventory
  needs an amendment of its own (it has no ICOS/SITES logs at all).
- On a fresh (empty) storage directory, rdfStore replays every configured RDF log from the
  `rdflog` database and then stays **read-only** on purpose. Verify the restore and run
  `ansible-playbook -i <inv> -t cpmetardfstore_restart rdfstore.yml` to get a writable,
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
