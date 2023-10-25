import os
from ansible.module_utils.basic import AnsibleModule
from subprocess import run

def find_docker_compose(module):
    """Find the command used to execute docker-compose.

    We want to support both the old "docker-compose" and the new "docker
    compose".
    """
    for cmd in ("docker compose", "docker-compose"):
        try:
            r = run([cmd, 'version'], check=0, capture_output=1)
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
            force_recreate=dict(required=False, type='bool', default=False)
        ),
        supports_check_mode=False)

    chdir = module.params['chdir']
    try:
        os.chdir(chdir)
    except FileNotFoundError:
        module.fail_json(f"Could not chdir() to '{chdir}'")

    dc = find_docker_compose(module)
    force = '--force-recreate' if module.params['force_recreate'] else ''

    r = run(f'{dc} up -d {force}', capture_output=1, text=1, shell=1, check=0)

    # docker-compose print status changes on stderr, usually nothing on stdout
    result = {'stdout': r.stdout, 'stdout_lines': r.stdout.splitlines(),
              'stderr': r.stderr, 'stderr_lines': r.stderr.splitlines(),
              }

    if r.returncode != 0:
        module.fail_json("Fail", **result)

    result['changed'] = any(line
                            for line in result['stderr_lines']
                            if not 'up-to-date' in line)
    result['changed'] |= bool(force)

    module.exit_json(**result)


if __name__ == '__main__':
    main()
