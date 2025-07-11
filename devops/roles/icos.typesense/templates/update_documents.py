# Update links from website in Typesense collection
# Should be run multiple times each day to ensure index is up to date
# Makes HEAD requests to the drupal server for each page and checks if ETag is different
# Note that webforms do not have ETags, so they will be re-checked every time

import typesense, json, time, yaml
from utilities import update_page, get_analytics, timestamp, url_to_id

typesense_api_key = "{{ vault_typesense_api_key }}"
base_url = '{{ base_urls[website] }}'

# Read schema from schema.yml to get collection name
with open("schema.yml", "r") as file:
    schema = yaml.safe_load(file)

print(timestamp() + f"[update_documents] Updates started for {schema['name']}.")

# Connect to Typesense client
client = typesense.Client({
  'nodes': [{
    'host': 'localhost',
    'port': '{{ typesense_port }}',
    'protocol': 'http'
  }],
  'api_key': typesense_api_key,
  'connection_timeout_seconds': 600
})

collection_name = schema["name"]

# .documents.export() returns a JSONLines string; split to get one JSON object per entry
documents = client.collections[collection_name].documents.export().split("\n")

documents_to_update_content = []
documents_to_update_analytics = []
documents_to_remove = []
links_to_check = []

links_seen = [base_url]

# Convert documents, a list of JSON strings, to objects, and then update each page if necessary
counter = 0
for line in documents:
    doc = json.loads(line)
    doc_status = update_page(doc)
    links_seen.append(doc["url"])
    if "status" in doc_status:
        status = doc_status["status"]
        if status == 404:
            documents_to_remove.append(doc)
        elif status == 301:
            documents_to_remove.append(doc)
            links_to_check.append(doc_status["dest"])
    elif doc_status["changed"]:
        documents_to_update_content.append(doc_status["doc"])
        links_to_check += doc_status["links"]
    else:
        documents_to_update_analytics.append(doc_status["doc"])
    counter += 1
    time.sleep(0.25)

# links_to_check contains any links from "updated" pages, as well as the destinations
# of redirected URLs. If the link has not been previously seen, we will freshly index the
# URL to be added to the collection. This ensures new pages are added as they are created.
for link in links_to_check:
    if link not in links_seen:
        links_seen.append(link)
        # need to freshly index this page
        doc_stub = {"id": url_to_id(link), "url": link}
        doc_status = update_page(doc_stub)
        if "status" in doc_status:
            if doc_status["status"] == 301:
                if doc_status["dest"] not in links_seen:
                    links_to_check.append(doc_status["dest"])
        elif doc_status["changed"]:
            documents_to_update_content.append(doc_status["doc"])
            links_to_check += doc_status["links"]
        time.sleep(0.25)


# Add analytics data
url_views = get_analytics()

documents_to_update = (documents_to_update_content + documents_to_update_analytics)

for doc in documents_to_update:
    url_path = doc["url"][len(base_url)-1:]
    num_views = 0
    if url_path in url_views:
        num_views = url_views[url_path]
    doc["num_views_last_year"] = num_views

# Update documents in Typesense collection
# using "emplace" to allow for partial updates as well as creations and full updates
updates_success = client.collections[collection_name].documents.import_(documents_to_update,{'action': 'emplace'})
success_count = sum(d['success'] for d in updates_success)

print(timestamp() + f"[update_documents] Updated documents for {schema['name']}: " + 
      f"{success_count}/{len(updates_success)} updates succeeded, of {len(documents)} total documents.")
if len(documents_to_remove) > 0:
    print(timestamp() + f"[update_documents] Removing documents for {schema['name']}:" + 
          f"{len(documents_to_remove)} documents to remove.")

# Remove documents with errors
for doc in documents_to_remove:
    deletion_success = client.collections[collection_name].documents[doc["id"]].delete({"ignore_not_found": True})
    if "url" in deletion_success:
        print(timestamp() + f"[update_documents] Deleted url={doc['url']}")
    else:
        print(timestamp() + f"[update_documents] Failed to delete url={doc['url']}")
