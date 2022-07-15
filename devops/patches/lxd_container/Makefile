ANSIBLE=$(shell ansible --version | awk '/ansible python module location/ { print $$6 }')
LXD_ORG=$(ANSIBLE)/../ansible_collections/community/general/plugins/modules/cloud/lxd/lxd_container.py
LIBRARY=../../library

.PHONY: update

update:
	cp $(LXD_ORG) $(LIBRARY)/lxd_container.py

patch:
	patch $(LIBRARY)/lxd_container.py lxd_container.diff

diff:
	diff -u $(LXD_ORG) $(LIBRARY)/lxd_container.py > lxd_container.diff || :
