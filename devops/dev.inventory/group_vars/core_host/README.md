## Deploying services from core.yml playbook to development machine

1. In order to deploy the core services locally on your development machine, create a `passwords.yml` file in this directory.
	
	In `passwords.yml`, all passwords needed to deploy the services locally should be stored as variables in plaintext.

	Example of passwords.yml:

		postgis_admin_pass: "admin_pass"
		postgis_reader_pass: "reader_pass"
		postgis_writer_pass: "writer_pass"

	Where `admin_pass`, `reader_pass` and `writer_pass` are the passwords used in your local database.

2. Add the following entry to `.gitignore`:

		devops/dev.inventory/group_vars/core_host/passwords.yml
