This script contains utilities for working with ICOS CP PostgreSQL
installations.

It's packaged as a python project and can be installed _both_ on servers and
on dev machines.

On servers it's installed by the containing icos.postgresql role.

On dev machines it can be installed by running:

    pipx install . --editable

Afterwhich the  `icos-postgresql` command is available.
