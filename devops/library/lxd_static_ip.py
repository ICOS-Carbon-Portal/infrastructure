from ansible.module_utils.basic import AnsibleModule
import json

# Finds the IP assigned by lxdbr0 and makes it static.

def find_ip_for_container(module, name):
    # We always look at lxdbr0, so we don't get tripped up by macvlan interfaces.
    _rc, stdout, _stderr = module.run_command(
        ['lxc', 'network', 'list-leases', 'lxdbr0', '-f', 'json'],
        check_rc=True)
    for d in json.loads(stdout):
        if d['hostname'] != name:  # skip other containers
            continue
        if ':' in d['address']:    # skip ipv6
            continue
        return d['type'] == 'static', d['address']
    module.fail_json(msg=f'Could not find container named {name}')


def find_interface_name(module, name, ip):
    # I couldn't find an easy way to find the interface name from outside the
    # container. It all depends on whether the interfaces comes from a profile
    # etc. It's easier to just look inside the container.
    _rc, stdout, _stderr = module.run_command(
        ['lxc', 'exec', name, '--', 'ip', '-j', 'a'], check_rc=True)
    for d in json.loads(stdout):
        ifname = d['ifname']
        for a in d['addr_info']:
            if a['local'] == ip:
                return ifname
    module.fail_json(f"Could not find ip {ip} in container {name}")


def configure_static_override(module, name, interface, ip):
    _rc, stdout, _stderr = module.run_command(
        ['lxc', 'config', 'device', 'override',
         name, interface, f'ipv4.address={ip}'], check_rc=True)


def main():
    global module
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(required=True, type='str')),
        supports_check_mode=True)

    name = module.params['name']

    static, ip = find_ip_for_container(module, name)
    result = {'changed': False, 'ip': ip, 'static': static,
              'ansible_facts': { f'{name}_ip': ip }}

    if not static:
        result['changed'] = True
        if not module.check_mode:
            interface = find_interface_name(module, name, ip)
            configure_static_override(module, name, interface, ip)
            result['interface'] = interface

    module.exit_json(**result)


if __name__ == '__main__':
    main()
