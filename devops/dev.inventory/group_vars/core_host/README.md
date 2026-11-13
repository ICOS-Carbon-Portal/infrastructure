## Deploying services from core.yml playbook to development machine

In order to deploy the core services locally on your development machine, make a copy of `example.passwords.yml` file in this directory named `passwords.yml`.

In `passwords.yml`, all database passwords needed to deploy the services locally are stored as variables in plaintext (and can be any arbitrary strings of your choice), while `ansible_become_pass` is your local `sudo` password encrypted with `ansible-vault`.

### Generating `ansible_become_pass`
1. Request the vault password from a colleague who already has access to it, and put the content in `~/.vault_password`.
2. Generate the encrypted string (replace `your_password` with your system's `sudo` password):
   ```bash
   ansible-vault encrypt_string --vault-password-file ~/.vault_password 'your_password' --name 'ansible_become_pass'
   ```
3. Paste the output into `passwords.yml`.

### Example of `passwords.yml`

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

#### Ubuntu 25.10+
Starting with Ubuntu 25.10, `sudo` is `sudo-rs` by default. 

Check with `sudo --version`: if it prints `sudo-rs`, add this line to `passwords.yml` so Ansible uses the classic `sudo` (installed as `sudo.ws`):

```yaml
ansible_become_exe: sudo.ws
```
