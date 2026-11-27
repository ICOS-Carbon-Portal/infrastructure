## Deploying services from core.yml playbook to development machine

In order to deploy the core services locally on your development machine, make a copy of `example.passwords.yml` file in this directory named `passwords.yml`.

In `passwords.yml`, all database passwords needed to deploy the services locally are stored as variables in plaintext (and can be any arbitrary strings of your choice), while `ansible_become_pass` is your local `sudo` password encrypted with `ansible-vault`.

### Generating `ansible_become_pass`
1. Request the vault password from a colleague who already has access to it, and put the content in `~/.vault_password`.
2. Generate the encrypted string; when prompted to enter a variable name, enter `ansible_become_pass`, then enter your system's sudo password:
   ```bash
   ansible-vault encrypt_string --vault-password-file ~/.vault_password --prompt
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
  34303064313562653264373438666230326665313632656234633765393930323866316134653062
  3462306362333836343037656430313838303862663635640a333534303035623636643234326139
  32643730653832643437396638353634306565663134386430646230663938373234653135653236
  6566626239656238320a303663363564636462386639363363313039313436646531303739306431
  6236
```

#### Ubuntu 25.10+
Starting with Ubuntu 25.10, `sudo` is `sudo-rs` by default. 

Check with `sudo --version`: if it prints `sudo-rs`, add this line to `passwords.yml` so Ansible uses the classic `sudo` (installed as `sudo.ws`):

```yaml
ansible_become_exe: sudo.ws
```
