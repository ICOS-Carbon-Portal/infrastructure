# Typesense

Typesense is used to power fast fuzzy searches for the Drupal websites.

## Using playbooks

Three tags exist for different purposes:

1) `setup` will run the setup/deployment tasks for the Typesense server.
2) `initialize_collection` will run the tasks required to set up an initial collection and perform a first
   index on a website, which must be provided. Note that any existing collection for that site will be
   deleted. Results of initialization and updates are logged to `{{ typesense_home }}/{{ website
   }}/collection.log` (e.g., could be `/docker/typesense/cp/collection.log`)
3) `timer` will restart the timer for updating the collection; website must be provided. Not necessary to run
   this unless the timer has stopped for some reason.

*Note: for consistency website codes should match those found in `drupal_websites`, found in
`icos.drupal/defaults/main.yml`*

### Usage

```
icos play typesense -t setup -DC
```

```
icos play typesense -t initialize_collection -e "website=cp" -DC
```

```
icos play typesense -t timer -e "website=cp" -DC
```

## Typesense collection creation and maintenance

The general overview of the scripts here is:
1) `init_collection.py` is used to create a new collection based on the defined schema in `schema.yml`.
2) `init_documents.py` is used to create the initial documents for the index by crawling the entire ICOS
   website and finding all pages that are actively linked, starting from the front page.
3) `update_documents.py` is a script that should be run regularly to keep the pages up to date. Every URL in
   the collection is queried using a HEAD request, and the received `ETag` is compared to the recorded `ETag`.
   If the tag is different (or not present, e.g. a webform), then the page is queried using a GET request, and
   the content of the page is updated, as well as the `ETag`. Analytics data is also updated for every page.
   The printed contents should be recorded to a log file somewhere.

`utilities.py` contains functions that the other scripts use, the two main functions being `update_page`, used
for updating a single page, and `get_all_pages`, which is used for finding all pages from the ICOS main site.
