#!/usr/bin/python
# -*- coding: utf-8 -*-
# Ansible module sets a fact to the contents of a file.

import json
from ansible.module_utils.basic import AnsibleModule

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

EXAMPLES = '''
- shellfact:
    exec: echo $SSH_CONNECTION | sed 's/ /\n/g'
    fact: ssh_connection
    list: true

- debug: var=ssh_connection

- shellfact:
    exec: |
      IP=$(echo $SSH_CONNECTION | cut -d ' ' -f 3);
      ssh-keyscan localhost | sed "s/^localhost/$IP/"
    fact: hostkeys

- name: Retrive postgresql cluster info
  shellfact:
    exec: pg_lsclusters -j
    fact: pg
    json: true

- debug: var=hostkeys
'''

def main():
    module = AnsibleModule(
        argument_spec={'exec': dict(required=True, type='str'),
                       'fact': dict(required=True, type='str'),
                       'list': dict(required=False, type='bool', default=False),
                       'json': dict(required=False, type='bool', default=False),
                       'rstrip': dict(required=False, type='bool', default=True)})

    rc, stdout, stderr = module.run_command(
        module.params['exec'], check_rc=True, use_unsafe_shell=True)
    value = stdout
    if module.params['rstrip']:
        value = value.rstrip()
    if module.params['list']:
        value = value.splitlines()
    if module.params['json']:
        value = json.loads(stdout)
    result = {'changed': False,
              'ansible_facts': {module.params['fact']: value}}
    module.exit_json(**result)


if __name__ == '__main__':
    main()
