
# Change PATH to your working git path:

# Example
cd <PATH>/git-icos/infrastructure/devops

# For just command run (Note: Omitting C parameter):
    just play icos-kronos-kvm -t kvm_snapshot -e domain=icos-srv1 -D -i ~/ansible/inventory.ini

