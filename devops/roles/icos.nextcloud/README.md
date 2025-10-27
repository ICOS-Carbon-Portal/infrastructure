## Nextcloud upgrade procedure

# Nextcloud Container Upgrade Checklist

## Step 1 - Preparation

- [ ] Test upgrade nextcloud in lab first
- [ ] Review nextcloud release notes for breaking changes
- [ ] Verify package requirements versions (PHP version, docker-compose, database)
- [ ] Document current state:
  - [ ] Make a list of all enabled apps
- [ ] Create backup:
  - [ ] Database backup
  - [ ] Config files backup (docker-compose.yml, config.php)

## Step 2 - Announce Update

- [ ] Announce and set a date for upgrading nextcloud
- [ ] Communicate and mail out date to users
- [ ] Schedule maintenance window
- [ ] Prepare rollback plan and communicate it to team

## Step 3 - Update Execution

- [ ] Enable maintenance mode
- [ ] Pull new nextcloud image
- [ ] Stop containers gracefully
- [ ] Update docker-compose.yml with new version
- [ ] Start containers
- [ ] Run upgrade command(s)
- [ ] Check logs for errors (in separate window)
- [ ] Disable maintenance mode

## Step 4 - Post-Update Verification

- [ ] Verify nextcloud version and status
- [ ] Compare enabled apps list with pre-update list
- [ ] Re-enable any disabled apps (if compatible)
- [ ] Verify critical functionality:
  - [ ] User login
  - [ ] File upload/download
  - [ ] Group/team fileshare
  - [ ] Calendar functionality
  - [ ] General mounting points
  - [ ] External storage
  - [ ] OnlyOffice connectivity/document editing
- [ ] Check system warnings in admin panel
- [ ] Review error logs

## Step 5 - Post-Update Communication

- [ ] Notify users that upgrade is complete
- [ ] Report any known issues or changes
- [ ] Update internal documentation
- [ ] Document and update ansible script for next upgrade


---


## Overview

Note! All nextcloud links in this file goes to the latest ("stable") versions
of the documentation, remember to change the version (by editing the URL) to
the version you intend to install.

* [Nextcloud release schedule][1]
* [Admin manual][2]
* [Discussion groups][3]


## Upgrading postgresql

Upgrading postgres between minor versions (which for versions 10 and beyond
means changing the second versions, i.e 10.8 to 10.14) can be done by just
upping the second version and starting the new container.

Upgrading between major versions, e.g version 10 to version 11, requires
either a dump/restore or a pg_upgrade, the later might prove tricky in a
container.

1. Check [which versions][5] of postgres are supported by nextcloud. Currently
   versions 9.[56], 10 and 11 are supported.
2. The [postgres version lifecycle][6] is available here. Currently we're
   running postgres 10, which is supported until October 2022.
3. Check [nextcloud notes][4] about postgres.
4. Find the latest [postgres docker tags][7]


## Upgrading Nextcloud

1: Check and if possible fix the [warnings on the admin page][8]


[1]: https://github.com/nextcloud/server/wiki/Maintenance-and-Release-Schedule
[2]: https://docs.nextcloud.com/server/stable/admin_manual/
[3]: https://help.nextcloud.com/
[4]: https://docs.nextcloud.com/server/stable/admin_manual/configuration_database/linux_database_configuration.html#postgresql-database
[5]: https://docs.nextcloud.com/server/stable/admin_manual/installation/system_requirements.html
[6]: https://www.postgresql.org/support/versioning/
[7]: https://hub.docker.com/_/postgres/?tab=tags
[8]: https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/security_setup_warnings.html


## Manual steps - Upgrading Nextcloud ver 29 to 31

The will be an ansible script for upgrading version 31.0.9.1 to version 32.
These notes were for upgrading from (old) minor versions, and will not be relevant for upgrading from the current version to version 32.X.


### From ver 29.0.11 to 29.0.16

```
# fsicos2
cd /docker/nextcloud

# Check docker-compose version
docker compose version

# Install Compose v2 plugin (from Docker’s repo)
apt-get update
apt-get install -y docker-compose-plugin

# Set nextcloud in maintenance mode on
docker compose exec -u www-data app php occ maintenance:mode --on || true

# Make a backup
docker-compose exec -u 33 db pg_dump -U nextcloud nextcloud > backup_29.0.11_$(date +%Y%m%d).sql

# Continue with
docker compose stop app

# Update docker-compose.yml to the next version
vi docker-compose.yml
grep "image: nextcloud:" docker-compose.yml

# In another session window check logs
docker-compose logs -f app

# Upgrade 
# Pull the new image and recreate the app
docker compose pull app
docker compose up -d app

docker compose exec -u 33 app php occ upgrade

# Check nextcloud version
docker compose exec -u www-data app php occ config:system:get version

# Check status
docker compose exec -u www-data app php occ status

# Create backup
mkdir -p /docker/nextcloud/backups
sudo chown $(id -u):$(id -g) /docker/nextcloud/backups

docker compose exec -T db pg_dump -U nextcloud -d nextcloud \
  > /docker/nextcloud/backups/pg_nextcloud_$(date +%F_%H%M%S).sql


# Config tarball
docker compose exec app bash -lc 'tar -C /var/www/html -czf - config' \
  > /docker/nextcloud/backups/nc_config_$(date +%F_%H%M%S).tar.gz
```


### From ver 29.0.16 to 30.0.16.1
```
# Set maintenace mode
docker compose exec -u www-data app php occ maintenance:mode --on

# Download image to Nextcloud 30

docker compose stop app
docker compose rm -f app
docker compose pull app
docker compose up -d app

# Run the upgrade
docker compose exec -u www-data app php occ upgrade
docker compose exec -u www-data app php occ app:update --all

# Repairs and checks schema 
docker compose exec -u www-data app php occ maintenance:repair
docker compose exec -u www-data app php occ db:add-missing-indices
docker compose exec -u www-data app php occ db:add-missing-columns
docker compose exec -u www-data app php occ db:add-missing-primary-keys

docker compose exec -u www-data app php occ db:convert-filecache-bigint --no-interaction


# Re-enable any apps you disabled (one by one is safest):
docker compose exec -u www-data app php occ maintenance:mode --off
docker compose exec -u www-data app php occ status

docker compose exec -u www-data app php occ config:system:get version
...................................................
30.0.16.1
...................................................

```


### Upgrade steps from version 30.0.16 to Nextcloud 31.0.9

```
# list enabled apps (spot non-shipped ones)
docker compose exec -u www-data app php occ app:list --enabled
docker compose exec -u www-data app php occ app:list --enabled --shipped


# Backup DB + config (recommended)
sudo mkdir -p /docker/nextcloud/backups
sudo chown $(id -u):$(id -g) /docker/nextcloud/backups

# Postgres dump
docker compose exec -T db pg_dump -U nextcloud -d nextcloud \
  > /docker/nextcloud/backups/pg_nextcloud_$(date +%F_%H%M%S).sql
  

# Config directory
docker compose exec app bash -lc 'tar -C /var/www/html -czf - config' \
  > /docker/nextcloud/backups/nc_config_$(date +%F_%H%M%S).tar.gz
  

# Set maintenance ON
docker compose exec -u www-data app php occ maintenance:mode --on

# Update docker-compose.yml the image to NC31
vi docker-compose.yml


# Recreate only the app container
docker compose stop app
docker compose rm -f app
docker compose pull app
docker compose up -d app


# Run the upgrade
docker compose exec -u www-data app php occ upgrade


# Post-upgrade 
docker compose exec -u www-data app php occ app:update --all
...................................................
Nextcloud or one of the apps require upgrade - only a limited number of commands are available
You may use your browser or the occ upgrade command to do the upgrade
passman new version available: 2.4.12
passman couldn't be updated
...................................................


# Repairs and schema checks
docker compose exec -u www-data app php occ maintenance:repair
docker compose exec -u www-data app php occ db:add-missing-indices
docker compose exec -u www-data app php occ db:add-missing-columns
docker compose exec -u www-data app php occ db:add-missing-primary-keys
docker compose exec -u www-data app php occ db:convert-filecache-bigint --no-interaction 2>/dev/null || true

# If we use Redis when clear caches
docker compose exec -u www-data app php occ memcache:flush 2>/dev/null || true

# Exit maintenance and verify
docker compose exec -u www-data app php occ maintenance:mode --off

# Check status 
docker compose exec -u www-data app php occ status
...................................................
  - installed: true
  - version: 31.0.9.1
  - versionstring: 31.0.9
  - edition:
  - maintenance: false
  - needsDbUpgrade: true
  - productname: Nextcloud
  - extendedSupport: false
...................................................


# Check NC version 
docker compose exec -u www-data app php occ config:system:get version
...................................................
31.0.9.1
...................................................
```


