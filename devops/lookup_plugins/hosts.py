try:
    from distutils.version import LooseVersion as Version
except ModuleNotFoundError:
    # https://github.com/pypa/packaging/issues/520#issuecomment-1067119795
    from packaging.version import Version
    
from ansible.errors import AnsibleError
from ansible.inventory.manager import InventoryManager
from ansible.plugins.lookup import LookupBase


# Use for debugging
# from ansible.utils.display import Display


DOCUMENTATION = r"""
  name: hosts
  description:
    - a list af inventory hosts matching a host pattern
    - optionally sorted by a common inventory variable
    - same as inventory_hostnames()
  options:
   _terms:
     description: host group(s)
     required: True
   how:
     type: string
     description:
       - How should the list be sorted?
     choices:
       standard: Standard sort order
       version: Interpret the list elements as versions
     default: standard
   var:
     type: string
     description:
       - A variable that all the hosts have in common (like "ip")
       - The host will be sorted by this.
     required: False
"""

EXAMPLES = """
- name: list all hosts in the group nebula sorted by their ip
  ansible.builtin.debug:
    msg: |
       {% for host in query('hosts', 'nebula_hosts',
                            var='nebula_ip', how='version') %}
          host={{ host }}
       {% endfor %}
"""

# for debugging
# display = Display


# Based upon this - builtin - lookup plugin.
# https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/lookup/inventory_hostnames.py


class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):
        self.set_options(var_options=variables, direct=kwargs)

        # d = display.display
        # d("{terms=} {variables=} {kwargs=}")

        manager = InventoryManager(self._loader, parse=False)
        for group, hosts in variables['groups'].items():
            manager.add_group(group)
            for host in hosts:
                manager.add_host(host, group=group)
        try:
            hosts = [h.name for h in manager.get_hosts(pattern=terms)]
        except AnsibleError:
            hosts = []
        
        if var := self.get_option('var'):
            if self.get_option('how') == 'version':
                f = lambda host: Version(variables['hostvars'][host][var])
            else:
                f = lambda host: variables['hostvars'][host][var]
            hosts.sort(key=f)
        return hosts
    
