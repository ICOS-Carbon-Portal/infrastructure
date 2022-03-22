# Deployment and development tools for ICOS Carbon Portal services

Deployment and provisioning of CP services is automated using Ansible.
All related configurations and definitions are found in `devops` folder of this repository.

Some of CP's own, in-house-developed, services, are built, packaged and deployed using SBT build tool. Source code of CP-specific SBT plugins can be found in folder `sbt`.

Other folders in this Git repository mostly contain legacy Docker files (used before the Ansible era).


# Getting started (common)
To get started, one needs:
- Ubuntu 20.04 LTS or an equivalent Linux distribution (e.g. Linux Mint 20)
- Git
- Docker
- docker-compose
- pip
- Ansible

To install all of the above, run

`sudo apt install git docker.io docker-compose python3-pip`

followed by

`pip3 install --user ansible==2.11.6`

(the recommended Ansible version will keep changing, so check with the team which one is relevant)

Make sure `ansible-playbook` is on your path. Get the ansible-vault password from a colleague and place it in file `~/.vault_password`.

# Getting started (Scala services)

To develop/build/deploy Scala-based services, install Java with

`sudo apt install openjdk-11-jdk`

and SBT by following the instructions on https://www.scala-sbt.org/

To be able to publish JAR artefacts to CP's Nexus repo, get the `.credentials` file from a colleague and place it into `~/.ivy2/` folder.


## rdflog
`rdflog` is a postgres database. It is a dependency of the `meta` service. To
setup a development environment for `meta` you first have to setup
`rdflog`.

The easiest way is to retrieve a copy of the production database and run it in
a docker container. In order to retrieve a copy of the production database
you'll need root access to the fsicos2 server, the following instructions
depends on it.

Please note that the following commands - even though fairly detailed - are
meant more as a guide than a precise step-by-step manual. The important thing
to understand is that we're dumping a postgresql database and then we're
restoring it again. Currently the source database is in docker, but it doesn't
have to be; currently it's on another host (requiring ssh), but it doesn't have
to be.

### Retrieve database
`ssh -p 6022 root@fsicos2.lunarc.lu.se 'cd /docker/rdflog && docker-compose exec -T db pg_dump -Cc --if-exists -d rdflog | gzip -c' > /tmp/rdflog_dump.gz`

This command will ssh to fsicos2, then change to the rdflog directory (in order to access docker-compose.yml) and execute `pg_dump` within the running rdflog database container. The `pg_dump` command makes sure to include `create database` commands. The default output of `pg_dump` is a text format which we pipe through gzip in order to cut down on transfer time. The result - basically a compressed sql file - is stored in /tmp on the local host.


### Start postgres container
`docker run -d --name postgres -ePOSTGRES_PASSWORD=p -p 127.0.0.1:5433:5432 postgres:10`

This will create a docker container or localhost. It requires that you've setup
docker on your machine and that you have enough privileges to run docker.

The docker container will:
* have the container name `postgres`
* be running in the background
* be available on port 5433 on localhost. note that 5433 is chosen as not to
  conflict with postgres' default port of 5432 which might be in use on
  localhost

### Restore backup into container
`zcat /tmp/rdflog_dump.gz | docker exec -i -u postgres postgres psql -q`

Now we extract the compressed sql file to standard output and pipe it into the
running postgres docker container, where the `psql` command will receive it and
execute it.


### Connect to database
If you don't have postgres installed on host:

`docker exec -it -u postgres postgres psql rdflog`

If you do have postgres installed on host:

`psql --host localhost --port 5433 -U postgres`

Likewise, if you need to connect to the postgres database using programmatic
means, point your program to localhost:5433 (don't forget the port number which
is not the default one)


### Shutdown and remove container.
`docker rm -f postgres`


## restheart
Needed by `data` and `cpauth` to run locally.

First, fetch `docker-compose.yml` and `security.yml` files:<br>
<!---`wget https://raw.githubusercontent.com/SoftInstigate/restheart/3.10.1/docker-compose.yml` --->
`curl -oL docker-compose.yml https://github.com/ICOS-Carbon-Portal/infrastructure/raw/master/devops/roles/icos.restheart/templates/docker-compose-dev.yml`<br>
`wget https://github.com/ICOS-Carbon-Portal/infrastructure/raw/master/devops/roles/icos.restheart/templates/security.yml`

Create and start RestHeart and MongoDB containers with<br>
`docker-compose up -d`

Recover RestHeart's MongoDB backup from BorgBackup in the same way as for rdflog.<br>
`borg list /disk/data/bbserver/repos/restheart.repo`

Copy the backup file `server.archive` to your machine and restore it into your MongoDB with<br>
`docker exec -i restheart-mongo mongorestore --archive --drop < server.archive`


## postgis
Used by `data` service to log object downloads and query for download stats.

Creating Docker container and installing PostGIS in it:<br>
`docker run -e POSTGRES_PASSWORD=blabla --name postgis -p 127.0.0.1:5438:5432 -d postgres:12.3`

Specify the password in `data` application.conf `cpdata.downloads.admin.password`

`docker exec -ti postgis /bin/bash`

`apt-get update && apt-get install postgresql-12-postgis-3`

Either create a new database or restore a backup


### Create the database
- Login to postgres inside the container `psql -U postgres`
- Create the two databases `CREATE DATABASE cplog; CREATE DATABASE siteslog;`
- Create two roles `CREATE USER reader WITH PASSWORD 'blabla'; CREATE USER writer WITH PASSWORD 'blabla';`
- Specify the passwords in `data` application.conf `cpdata.downloads.reader.password` and `cpdata.downloads.writer.password`


### OR Recover postgis' backup from BorgBackup on fsicos2
The backup is expected to be an SQL cluster dump of Postgres in a file named `stdin`.<br>
`borg list /disk/data/bbserver/repos/postgis.repo | tail`

Restoring from the cluster dump made with `pg_dumpall`:<br>
`egrep -v '^(CREATE|DROP) ROLE postgres;' ./stdin | docker exec -i postgis psql -v ON_ERROR_STOP=1 -f - -U postgres`


## meta
Deploy rdflog on your development machine. Clone the repository from GitHub. Copy `application.conf` from your old machine, or from your fellow developer. Alternatively, create `application.conf` from scratch, and then look at `meta`'s default `application.conf` in `src/main/resources` to determine what settings need to be overridden. At a minimum, the following is needed:<br>
```
cpmeta{
    rdfLog{
        server.port: 5433
        credentials{
            db: "rdflog"
            user: "rdflog"
            password: "look up in fsicos2:/home/cpmeta/application.conf"
        }
    }
    citations.eagerWarmUp = false
}
```
When starting `meta` for the first time, if you don't have RDF storage folder preserved from another machine/drive, the service will go into a "fresh init" mode of initialization from RDF logs, with no indices created, neither RDF4J nor CP ones. The service will issue a warning. This mode can also be triggered by a local config:
```
cpmeta.rdfStorage.recreateAtStartup = true
```
You'll need to restart the service after the "fresh init". Initialization may take long time (~1 hour)


# Getting started (front end apps)
## Nodejs and npm
Needed for running the front-end build tools.

Install Node.js according to [NodeSource](https://github.com/nodesource/distributions#debinstall) (choose Node.js v12.x), it will include npm (Ubuntu 20.04 will be supported only after its official release).


## Nginx
Move `/etc/nginx` folder and `/etc/hosts` file from your previous machine.


# Useful commands
To get a list of Docker container IDs together with their Linux process IDs (run as root):
`docker ps | awk '{print $1}' | tail -n +2 | xargs docker inspect -f '{{ .Config.Hostname }} {{ .State.Pid }}'`

To purge unused Docker images:
`docker rmi $(docker images --filter "dangling=true" -q --no-trunc)`

To get a list of top 10 processes by memory usage:
`ps aux --sort -rss | head -n 10`

To get process' command:
`ps -fp <pid>`

To see all parents and direct children of a process:
`pstree -p -s <pid>`

Working dir of a process by id:
`pwdx <pid>`


## Restheart
Users that specified ORCID ID in their user profile:

`curl -G --data-urlencode 'keys={"_id":1, "profile.orcid":1}' --data-urlencode 'filter={"profile.orcid":{"$regex": ".+"}}' http://127.0.0.1:8088/db/users?count=true`

Get popular variables in time serie previews:

`curl -o page1.json 'https://restheart.icos-cp.eu/db/portaluse/_aggrs/getPopularTimeserieVars?pagesize=10&page=1'`

Transform download counts json from the previous command to tsv (requires jq installed):

`cat page1.json | jq -r '._embedded[] | [.count, .ip, .megabytes] | @tsv' > page1.tsv`

Sort the results by download count descending:

`cat page1.tsv page2.tsv | sort -nr > icos_dl_stats_2018-03-27.tsv`
