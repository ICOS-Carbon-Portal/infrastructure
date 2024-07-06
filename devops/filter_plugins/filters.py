from packaging.version import Version
import ipaddress


def version_sort(l):
    return sorted(l, key=Version)


def ip_sort(l):
    return sorted(ipaddress.ip_interface(elt).ip for elt in l)


def sort_by_key(d, key, filter=None):
    def get_key(t):
        v = t[1][key]
        match filter:
            case None: return v
            case 'version': return Version(v)
    return sorted(d.items(), key=get_key)


class FilterModule(object):

    def filters(self):
        return {
            'version_sort': version_sort,
            'ip_sort': ip_sort,
            'sort_by_key': sort_by_key
            }
