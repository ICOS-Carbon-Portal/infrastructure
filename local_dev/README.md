# Local development support services

The contents of this directory serves as executable documentation for running the required services in order
to do local development of the [meta](https://github.com/ICOS-Carbon-Portal/meta) and
[data](https://github.com/ICOS-Carbon-Portal/data) services. The main goal is getting things up-and-running
quickly, while more detailed documentation can be found in the main
[README](https://github.com/ICOS-Carbon-Portal/infrastructure) of this repository.

The main entry point is [this justfile](./justfile) and the support services are run in an LXD container.
Before you get started, install these tools.

### Tools needed:
- [just](https://github.com/casey/just)
- [LXD/LXC](https://ubuntu.com/server/docs/lxd-containers)
- nginx
- mkcert
- borgbackup

### Manual preparation
- Clone infrastructure, data and meta repositories.
- Create a `.vault_password` file in this directory (`infrastructure/local_dev`), with contents given to you
  by a colleague.
- Minimal configs for [data](https://github.com/ICOS-Carbon-Portal/data) and
  [meta](https://github.com/ICOS-Carbon-Portal/meta) services can be found in
  [example_configs](./example_configs). If you are in this directory and the data and meta repositories are in
  the same directory as infrastructure:

```
cp example_configs/data_application.conf ../../data/application.conf
cp example_configs/meta_application.conf ../../meta/application.conf
```

- You should run `lxd init` before proceeding. To run this, you probably need to add yourself to the lxd group
  (`sudo adduser USERNAME lxd`) and change your primary group to lxd (`newgrp lxd`). You can use the defaults
  for each question asked.
- Note: You will probably run into a conflict between Docker and LXD, preventing networking from working
  properly inside LXD containers. To fix this, edit `/etc/sysctl.d/99-sysctl.conf` file and enable the line
  `net.ipv4.ip_forward=1`, which enables IPv4 forwarding, then restart your machine.
- Note: On Windows/WSL Ubuntu, you may need to change the binding addresses for data/meta to use 0.0.0.0
  instead of 127.0.0.1 by editing the `application.conf` files and adding the appropriate line to each
  service.

### Running

You should now be able to run:
```
just create-vm run-playbooks
```
If this succeeds, an LXC container with the required services should now be running, and you should be able to
run both the `meta` and `data` services.

- Note: If you have permission issues on `.vault_password` after it's copied, set the correct permissions via
  `lxc exec icos-devops chown ubuntu:ubuntu /home/ubuntu/.vault_password`

Next, you need to set up nginx to work as a proxy, using the datalocal.icos-cp.eu and metalocal.icos-cp.eu
domains. Unfortunately nginx must currently be run from outside of the container, on the local machine.

1. Append the contents of `nginx/hosts` to your `etc/hosts` file.
2. Change directory to the nginx folder, then run the `make_certs.sh` script.
3. Place nginx config in `/etc/nginx/conf.d` and reload nginx, after testing the config:
```bash
sudo mv nginx.conf /etc/nginx/conf.d
sudo nginx -t
sudo systemctl reload nginx
```
4. Alternatively, if you use the `nginx` command to start and stop the service, you can run
  `nginx -c /absolute/path/to/infrastructure/local_dev/nginx/nginx.conf`

Now, if you navigate to `datalocal.icos-cp.eu` from the machine after starting the data app, you should be
able to access the front-end properly. (Even without running the data app, you should get an nginx 502 Bad
Gateway page, instead of a "The provided host name is not valid for this server." warning.)


### Development/Testing

When working on the `ansible` roles in this repository, the quickest way to test the results is to run
```
just init-vm run-playbooks
```
The task `init-vm` will use a snapshot of the LXC container in order to skip most of the setup, and copy the
local state of this repository into the container. If there are errors in the edited playbooks, it is best to
simply run `just run-playbooks` until they work, rather than `init-vm` every time.

To start the container completely from scratch, use `just reset-vm` or `just destroy-vm`.

### Restoring backups

To properly use rdflog and restheart, you will need to restore a backup from the server. Instructions here are
from the main `README.md` file for the repository, but tailored for this containerized approach and put into
the justfile.

rdflog:

```
just restore-rdflog
```

Note that the above command restores the entire production database for rdflog. This is probably not necessary
for local development; ideally we should have a subset for development, containing examples of the different
data types, but we have not yet constructed this.

Instead, we can reduce the size of the rdflog database to be more reasonable by deleting the most recent data
from the largest tables:

bash, one at a time:
```bash
lxc exec icos-devops bash
docker exec -it rdflog bash
psql -U rdflog
```

Inside psql shell:
```sql
DELETE FROM atmprodcsv WHERE tstamp > NOW() - INTERVAL '36 months';
DELETE FROM etccsv WHERE tstamp > NOW() - INTERVAL '36 months';
DELETE FROM etcprodcsv WHERE tstamp > NOW() - INTERVAL '36 months';
DELETE FROM atmcsv WHERE tstamp > NOW() - INTERVAL '36 months';
VACUUM FULL atmcsv;
VACUUM FULL etccsv;
VACUUM FULL etcprodcsv;
VACUUM FULL atmprodcsv;
```

Extend interval as desired if it is still too large. You can examine the largest tables with:
```sql
SELECT
  relname AS "Table",
  pg_size_pretty(pg_total_relation_size(relid)) AS "Size"
FROM
  pg_catalog.pg_statio_user_tables
ORDER BY
  pg_total_relation_size(relid) DESC;
```

restheart:

```
just restore-restheart
```

postgis:
```
just restore-postgis
```

If there are errors, you can run update-postgis to continue to run and fix the user passwords:
```
just update-postgis
```

To remove the backup files from the container:

```
just clean-container-backups
```

### Troubleshooting

- If `data` will not run because the Postgis client can't connect, ensure the passwords are in the
  `application.conf` file located at the root of the repository.
- If unable to connect to the network from inside an LXD container, see the note above about enabling IPv4
  forwarding.

