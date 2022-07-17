from ansible.module_utils.basic import AnsibleModule
import yaml

# Finds the IP assigned by lxdbr0 and makes it static.

def find_static_ip_devices(name):
    rc, stdout, _stderr = module.run_command(
        ['lxc', 'config', 'device', 'show', name], check_rc=False)
    r = {}
    if rc == 0:
        for dn, dv in yaml.safe_load(stdout).items():
            if dv.get('type') == 'nic':
                r[dn] = dv
    return r


def main():
    global module
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(required=True, type='str')))

    name = module.params['name']

    result = {'changed': False, 'devices': find_static_ip_devices(name)}

    module.exit_json(**result)


if __name__ == '__main__':
    main()
