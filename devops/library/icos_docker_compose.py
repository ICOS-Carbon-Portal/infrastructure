import os
import subprocess
from ansible.module_utils.basic import AnsibleModule

def run(cmd, **kwargs):
    default = {"check": False, "text": True, 'capture_output': True}
    if isinstance(cmd, str):
        default["shell"] = True
    default.update(kwargs)
    # docker-compose print status changes on stderr, usually nothing on stdout
    r = subprocess.run(cmd, **default)
    d = {'stdout': r.stdout, 'stdout_lines': r.stdout.splitlines(),
         'stderr': r.stderr, 'stderr_lines': r.stderr.splitlines(),
         'cmd': cmd}
    return r, d


def find_docker_compose(module):
    """Find the command used to execute docker-compose.

    We want to support both the old "docker-compose" and the new "docker
    compose".
    """
    for cmd in ("docker compose", "docker-compose"):
        try:
            r, _ = run(f'{cmd} version')
        except FileNotFoundError:
            continue
        if r.returncode == 0:
            return cmd
    module.fail_json("Couldn't execute 'docker compose' nor 'docker-compose'")


def main():
    global module
    module = AnsibleModule(
        argument_spec=dict(
            chdir=dict(required=True, type='str'),
            force_recreate=dict(required=False, type='bool', default=False),
            pull=dict(required=False, type='bool', default=False),
            build=dict(required=False, type='bool', default=False)
        ),
        supports_check_mode=False)

    chdir = module.params['chdir']
    try:
        os.chdir(chdir)
    except FileNotFoundError:
        module.fail_json(f"Could not chdir() to '{chdir}'")

    dc = find_docker_compose(module)
    up = f'{dc} up -d'

    if module.params['pull']:
        # version 1 does not have 'up --pull', so we'll have to pull
        # separately.
        if dc == 'docker-compose':
            r, d = run(f'{dc} pull --quiet', capture_output=1, shell=1, check=0)
            if r.returncode != 0:
                module.fail_json("Fail", **d)
        else:
            up += ' --pull always --quiet-pull'

    if module.params['force_recreate']:
        up += ' --force-recreate'

    if module.params['build']:
        up += ' --build'

    r, result = run(up)
    if r.returncode != 0:
        module.fail_json("Fail", **result)

    result['changed'] = any(line
                            for line in result['stderr_lines']
                            if not ('up-to-date' in line
                                    or 'Running' in line))
    result['changed'] |= module.params['force_recreate']

    module.exit_json(**result)


if __name__ == '__main__':
    main()
