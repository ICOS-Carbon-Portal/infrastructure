# Summary

## This roles installs custom python CLI utilities

+ It makes sure that they end up in their own virtual environments
+ It installs dependencies
+ It installs entrypoints on $PATH
+ It makes them easy to upgrade and reinstall
+ It allows you to easily install/uninstall the util on your own machine while
  developing it.


## How does it work?

+ You put your script in a directory along with a pyproject.toml
+ You point this role to the directory
+ The role will copy the directory to the target and run pipx to setup a venv
  and create entrypoint scripts in $PATH


# Longer explanation
## Why do we install custom CLIs on our servers?

Even though our servers are provisioned using ansible, we still need to login
every now and then to perform maintenance and troubleshooting - for these
occasions we often use custom cli scripts.

As an example, when we deploy Nextcloud we also deploy a small python script
that helps us interact with the running nextcloud instance.


## Why do we use python for these scripts?

+ Python is available for all operating systems, architectures and distros.
+ It's almost as expressive as bash for command-line work while the syntax is
  far easier to remember
+ It has a rich ecosystem of third-party packages, e.g for connecting to
  docker.


## How can I run a utility on my dev machine?

Running the utility can be useful during development. To install the utility locally simply do:

    cd directory_containing_pyproject.toml
    pipx install --editable .

Now you'll be able to run the utility locally. The pipx installation is not a
copy of the util directory by points to it - so any changes you do in the
utility directory will take effect immediately.

Once you're done developing, remove the util:

    pipx uninstall name_of_util


## Python and virtual environments

Unless you're only using the standard library, your script should be installed
in it's own virtual environment.


### What happens if you dont use a separate venv when installing packages

Because then you mess with the system's own virtual environment. If you run
the following command on a server:

    pip install click

You install the "click" package (which is nice!) into the system's own virtual
environment.

This environment used used by the python script bundled with the system
itself. E.g Ubuntu uses a lot of python script for basic system functionality
and you're messing with these scripts if you do plain "pip install"

The solution is to *always use a separate venv*


### But virtual environments are cumbersome! (use pipx)

Not if one uses [pipx](Install and Run Python Applications in Isolated Environments  "pipx")

If you write a simple pyproject.toml file (the new standard for describing
python projects) and point pipx to it, pipx will:
+ Create a standalone virtual environment
+ Install your project and it's dependencies there
+ Create scripts in $PATH for your entrypoints


### Where does pipx come from?

It's installed by the [icos.python3 role](devops/roles/icos.python3)
