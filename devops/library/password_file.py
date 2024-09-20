# ansible module to load a password from file on target

from ansible.module_utils.basic import AnsibleModule
from pathlib import Path
import secrets


def main():
    global module
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(required=True, type='str'),
            path=dict(required=True, type='path'),
            length=dict(required=False, type='int', default=32)),
        supports_check_mode=True)

    result = {'changed': False}

    path = Path(module.params['path'])
    try:
        password = path.read_text()
    except:
        password = None
    else:
        if len(password) != module.params['length']:
            password = None

    if password is None:
        result['changed'] = True

    if password is None and not module.check_mode:
        path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        password = secrets.token_hex(module.params['length'] // 2)
        path.touch(mode=0o600, exist_ok=True)
        path.write_text(password)

    if password is not None:
        result['ansible_facts'] = {module.params['name']: password}

    module.exit_json(**result)


if __name__ == '__main__':
    main()
