## Deploying services from core.yml playbook to development machine

In order to deploy the core services locally on your development machine, create a `passwords.yml` file in this directory.
	
In `passwords.yml`, all passwords needed to deploy the services locally should be stored as variables in plaintext.

Example of passwords.yml:

	postgis_admin_pass: "admin_pass"
	postgis_reader_pass: "reader_pass"
	postgis_writer_pass: "writer_pass"
	rdflog_db_pass: "rdflog_db_pass"

	ansible_become_pass: !vault |
			$ANSIBLE_VAULT;1.1;AES256
			64363464653533656636366538626538613330363264333436373565316266343832313933333766
			3763336530636265663465306665393531626264353535340a313033363630333430386462626262
			64643363373464363166333034666637353432316137343138313131656637346337363435663834
			3139356666643839660a613662306632666637303731343731366132396538396339383534333837
			3937

Where `admin_pass`, `reader_pass` and `writer_pass` are the passwords used in your local database, and `ansible_become_pass` is your root user password.
To encrypt a single password, use the command:

	ansible-vault encrypt_string --vault-password-file .vault_password 'your_password' --name 'ansible_become_pass'
