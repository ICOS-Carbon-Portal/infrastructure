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

Nginx and backup tasks are opt-in only:

```sh
ansible-playbook -i production.inventory -t drupal_nginx -e website=all drupal.yml
ansible-playbook -i production.inventory -t drupal_backup drupal.yml
```
