# DevOps

This directory contains our framework to automatically provision (setup /
install software) on our different servers.

The framework is based around Ansible for provisioning and Vagrant/VirtualBox
for testing.

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

### Updating Drupal

Deployment defaults to `update=false`: it pulls/recreates containers and clears caches,
but skips maintenance mode, Composer updates, and database updates.

For a full ACTRIS update using the installed justfile shim:

```sh
icos play drupal -t drupal -e website=ac -e update=true
```

To update all configured websites:

```sh
icos play drupal -t drupal -e website=all -e update=true
```

Without the shim, from the repository root:

```sh
just --unstable --justfile devops/justfile play drupal -t drupal -e website=all -e update=true
```

These commands target production. Ensure a current backup exists before updating.
Drupal's database access is checked after container recreation, before running
Drupal commands, and the homepage check retries transient failures. If an update
fails after enabling maintenance mode, resolve the failure and rerun; maintenance
mode may remain enabled.

### Persistent application files

Drupal's `web/` directory (including core) and `vendor/` use separate named Docker
volumes, so container recreation preserves the installed application version.
The whole `web/` parent is mounted because Composer must be able to replace the
`core/` directory during updates. Existing bind mounts for uploaded files, themes,
modules, and libraries remain in place.

`composer.lock` is stored at `{{ project_dir }}/composer/composer.lock` on the
host and mounted into the container. Before the first recreation, the playbook
copies the existing container's lock file if the host file is absent. For a new
site it reads the image's initial lock file instead. Existing host locks are never
overwritten by this migration; Composer maintains them during updates.

All configured sites have migrated to persistent core. ACTRIS was verified after
container recreation without a core repair; normal deployments no longer perform
the migration-only sync step. Docker seeds new volumes from the image, so do not
pair a newly created `web` volume with an existing `vendor` volume without first
reconciling their core versions.

The nightly Borg backup covers the project directory, including
`composer/composer.json` and `composer/composer.lock`, but not the `web` and
`vendor` named volumes. To restore a site, restore the project directory, remove
both volumes so Docker reseeds them from the image, start the containers, and run
`composer install` in the Drupal container to rebuild core and dependencies from
the restored lock file. Then run `drush updb -y` and `drush cr`. Never remove only
one of the two volumes. Do not remove the volumes when recreating containers.
Changing only the image no longer updates persistent core: use `update=true` for
Drupal updates.

Nginx and backup tasks are opt-in only:

```sh
ansible-playbook -i production.inventory -t drupal_nginx -e website=all drupal.yml
ansible-playbook -i production.inventory -t drupal_backup drupal.yml
```
