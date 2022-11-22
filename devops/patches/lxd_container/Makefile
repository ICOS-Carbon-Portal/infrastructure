# 1. run 'make update' - check diff using git
# 2. commit changes (temporarily)
# 3. run 'make patch' - check diff using git again.
# 4. if the changes looks good, run 'make diff'
# 5. squash changes into final commit

ANSIBLE=$(shell ansible --version | awk '/ansible python module location/ { print $$6 }')
LXD_ORG=$(ANSIBLE)/../ansible_collections/community/general/plugins/modules/lxd_container.py
LIBRARY=../../library

.PHONY: update

update:
	cp $(LXD_ORG) $(LIBRARY)/lxd_container.py

patch:
	patch $(LIBRARY)/lxd_container.py lxd_container.diff

diff:
	diff -u $(LXD_ORG) $(LIBRARY)/lxd_container.py > lxd_container.diff || :
