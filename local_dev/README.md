# Local development support services

The contents of this directory serves as executable documentation for running the required services in order to do local development of the [meta](https://github.com/ICOS-Carbon-Portal/meta) and [data](https://github.com/ICOS-Carbon-Portal/data) services.
The main goal is getting things up-and-running quickly, while more detailed documentation can be found in the main [README](https://github.com/ICOS-Carbon-Portal/infrastructure) of this repository.

The main entry point is [this justfile](./justfile) and the support services are run in an LXD container.
Before you get started, install these tools.

### Tools needed:
- [just](https://github.com/casey/just)
- [LXD/LXC](https://ubuntu.com/server/docs/lxd-containers)
- nginx
- mkcert

### Manual preparation
- Clone infrastructure, data and meta repositories.
- Create a `.vault_password` file in this directory (`infrastructure/local_dev`), with contents given to you by a colleague.
- Minimal configs for [data](https://github.com/ICOS-Carbon-Portal/data) and [meta](https://github.com/ICOS-Carbon-Portal/meta) services can be found in [example_configs](./example_configs). If you are in this directory and the data and meta repositories are in the same directory as infrastructure:

```
cp example_configs/data_application.conf ../../data/application.conf
cp example_configs/meta_application.conf ../../meta/application.conf
```

- You should run `lxd init` before proceeding. To run this, you probably need to add yourself to the lxd group (`sudo adduser USERNAME lxd`) and change your primary group to lxd (`newgrp lxd`).
- Note: if using Ubuntu through WSL on Windows, you will need to enable IPv4 forwarding by editing the `/etc/sysctl.d/99-sysctl.conf` file and restarting the wsl service; otherwise the lxd container will not be able to fetch files from the internet. Additionally, you will probably need to change the binding addresses for data/meta to use 0.0.0.0 instead of 127.0.0.1 by editing the `application.conf` files and adding the appropriate line to each service.

### Running
You should now be able to run:
```
just create-vm run-playbooks
```
If this succeeds, an LXC container with the required services should now be running, and you should be able to run both the `meta` and `data` services.

Next, you need to set up nginx to work as a proxy, using the datalocal.icos-cp.eu and metalocal.icos-cp.eu domains.
Unfortunately nginx must currently be run from outside of the container, on the local machine.

1. Copy the contents of `nginx/hosts` to your `etc/hosts` file.
2. Change directory to the nginx folder, then run the `make_certs.sh` script.
3. Run nginx: `nginx -c /absolute/path/to/infrastructure/local_dev/nginx/nginx.conf`

Now, if you navigate to `datalocal.icos-cp.eu` from the machine after starting the data app, you should be able to access the front-end properly.


### Development/Testing

When working on the `ansible` roles in this repository, the quickest way to test the results is to run
```
just init-vm run-playbooks
```
The task `init-vm` will use a snapshot of the LXC container in order to skip most of the setup, and copy the local state of this repository into the container.
If there are errors in the edited playbooks, it is best to simply run `just run-playbooks` until they work, rather than `init-vm` every time.

To start the container completely from scratch, use `just reset-vm` or `just destroy-vm`.
