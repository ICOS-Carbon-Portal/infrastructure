# icos-deploy

Small utility to simplify the running of our ansible playbooks.

Basically it turns this command:

    icos run prom/vm conf

Into this:

    cd $INFRASTRUCTURE_REPO/devops
    ansible-playbook -i production.inventory prometheus/vmagent.yml -tconf

It finds the infrastructure repo by starting at the current directory and going
upwards. The reason you'll want to change to the infrastructure directory first
is because ansible finds inventories/roles/playbooks based on the current
working directory.


## Installing this script

The deploy script is written in python and the easiest way to use it is to
install it using pipx in editable mode. That way it won't pollute your python
environment and it'll always reflect the infrastructure repo.

First install pipx if you don't already have it (pipx is by the way the
preferable way to install ansible)

    pip install --user pipx

Then use pipx to install this utility (you have to be in this directory for it to work)

    pipx install --editable .

Which will output something like:

      installed package icos-deploy 0.0.1, installed using Python 3.10.6
      These apps are now globally available
        - icos
    done! ✨ 🌟 ✨

The phrase "these apps are now globally available" means that you can now run
the "icos" command.


## Installing ansible

If you haven't installed ansible, do that as well:

    pipx install ansible

Our ansible playbooks are developed using the latest version of ansible. Once
you've installed ansible using pipx, upgrading ansible is as easy as:

    pipx upgrade ansible


## Naming things

The name "icos" is not terribly well chosen. If anyone knows how to choose the
name of the script (i.e the entry-point script created by pip) at install time,
let me know.
