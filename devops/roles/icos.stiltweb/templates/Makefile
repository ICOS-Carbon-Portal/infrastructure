# This Makefile serves as a place to keep commands that are useful when
# maintaining the stiltweb app. To try it, use 'make status'.

status:
	systemctl {{ stiltweb_servicename }}

watch:
	{{ stiltweb_bin_dir }}/tail-latest.sh

sync: sync-fsicos1-to-fsicos2 sync-stilt-to-stiltweb sync-station-names sync-csv-files

sync-fsicos1-to-fsicos2:
	{{ stiltweb_bin_dir }}/sync-fsicos1-to-fsicos2.sh

sync-stiltweb-to-stilt:
	{{ stiltweb_bin_dir }}/sync-stiltweb-to-stilt.py

sync-stilt-to-stiltweb:
	{{ stiltweb_bin_dir }}/sync-stilt-to-stiltweb.py

sync-station-names:
	{{ stiltweb_bin_dir }}/sync-station-names.sh

sync-csv-files:
	{{ stiltweb_bin_dir }}/sync-csv-files.py

