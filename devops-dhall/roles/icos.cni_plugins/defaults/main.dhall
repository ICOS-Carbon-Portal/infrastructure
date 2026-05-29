-- Auto-generated from ../../../../devops/roles/icos.cni_plugins/defaults/main.yml

{
    cni_plugin_url = "https://github.com/containernetworking/plugins/releases/download/{{ podman_release.tag }}/cni-plugins-linux-{{ podman_arch[ansible_machine] }}-{{ podman_release.tag }}.tgz"
}
