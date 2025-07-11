# Add documents to the Typesense server
import typesense, yaml
from utilities import get_all_pages, get_analytics, timestamp, url_to_id

typesense_api_key = "{{ vault_typesense_api_key }}"
base_url = '{{ base_urls[website] }}'

# Read schema from schema.yml
with open("schema.yml", "r") as file:
    schema = yaml.safe_load(file)

print(timestamp() + f"[init_documents] Initialization started for {schema['name']}.")

url_views = get_analytics()

# Crawl site and prepare for document creation
documents = get_all_pages()

for doc in documents:
    url_path = doc["url"][len(base_url)-1:]
    num_views = 0
    if url_path in url_views:
        num_views = url_views[url_path]
    doc["num_views_last_year"] = num_views
    doc["id"] = url_to_id(doc["url"])

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

document_success = client.collections[collection_name].documents.import_(documents, {'action': 'create'})
success_count = sum(d['success'] for d in document_success)

print(timestamp() + f"[init_documents] Initialization for {schema['name']} finished with " + 
      f"{success_count}/{len(document_success)} documents created successfully.")
