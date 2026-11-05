## Deploying services from core.yml playbook to development machine

In order to deploy the core services locally on your development machine, make a copy of `example.passwords.yml` file in this directory named `passwords.yml`.

In `passwords.yml`, all database passwords needed to deploy the services locally are stored as variables in plaintext (and can be any arbitrary strings of your choice), while `ansible_become_pass` is your local `sudo` password encrypted with `ansible-vault`.

Example of `passwords.yml`:

```yaml
rdflog_db_pass: "rdflog_db_pass"

postgis_admin_pass: "admin_pass"
postgis_reader_pass: "reader_pass"
postgis_writer_pass: "writer_pass"

ansible_become_pass: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  64363464653533656636366538626538613330363264333436373565316266343832313933333766
  3763336530636265663465306665393531626264353535340a313033363630333430386462626262
  64643363373464363166333034666637353432316137343138313131656637346337363435663834
  3139356666643839660a613662306632666637303731343731366132396538396339383534333837
  3937
```

### What each variable does:
- **`rdflog_db_pass`**: Any password of your choice. Ansible uses it to initialize the `rdflog` user in your local `rdflog` PostgreSQL container (`127.0.0.1:2345`). Use this same password in your local `meta` `application.conf` under `cpmeta.rdfLog.credentials.password`.
- **`postgis_admin_pass`, `postgis_reader_pass`, `postgis_writer_pass`**: Any passwords of your choice (only needed if setting up `postgis` for the `data` service). When running `-t postgis_setup`, Ansible creates a local `postgis` container (`127.0.0.1:5438`) and sets these passwords for the `postgres` (admin), `reader`, and `writer` database roles. When `core_restore.yml` restores the production backup, it strips out `CREATE/ALTER ROLE` statements so your chosen local passwords remain intact. If you run the `data` (`cpdata`) service locally, set these same three passwords in `data`'s `application.conf` under:
  - `cpdata.postgis.admin.password`
  - `cpdata.postgis.reader.password`
  - `cpdata.postgis.writer.password`
- **`ansible_become_pass`**: Your local Linux user's `sudo` password.

### Generating `ansible_become_pass`
1. Request the vault password from a colleague who already has access to it, and put the content in `~/.vault_password`.
2. Generate the encrypted string (replace `your_password` with your system's `sudo` password):
   ```bash
   ansible-vault encrypt_string --vault-password-file ~/.vault_password 'your_password' --name 'ansible_become_pass'
   ```
3. Paste the output into `passwords.yml`.
