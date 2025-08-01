# Create a new Typesense collection based on the schema
import typesense, yaml
from utilities import timestamp

typesense_api_key = "{{ vault_typesense_api_key }}"

# Read schema from schema.yml
with open("schema.yml", "r") as file:
    search_schema = yaml.safe_load(file)

# Define schema for analytics, both popular queries and nohits queries
popular_schema = {
  "name": search_schema["name"] + "-popular-queries",
  "fields": [
    {"name": "q", "type": "string" },
    {"name": "count", "type": "int32" }
  ]
}

nohits_schema = {
  "name": search_schema["name"] + "-nohits-queries",
  "fields": [
    {"name": "q", "type": "string" },
    {"name": "count", "type": "int32" }
  ]
}

# Instantiate client
client = typesense.Client({
  'nodes': [{
    'host': 'localhost',
    'port': '{{ typesense_port }}',
    'protocol': 'http'
  }],
  'api_key': typesense_api_key,
  'connection_timeout_seconds': 600
})

# Delete existing collection for search, to allow for new schema
# Analytics schema should not change and we want to keep results when re-creating search collection
try:
    client.collections[search_schema["name"]].delete()
except:
    pass

search_success = client.collections.create(search_schema)

if "name" in search_success:
    print(timestamp() + f"[init_collection] Search collection with name={search_success['name']} created successfully.")
else:
    print(timestamp() + f"[init_collection] Collection creation for schema name = {search_schema['name']} failed.")

popular_success = client.collections.create(popular_schema)
nohits_success = client.collections.create(nohits_schema)

popular_rule_name =  popular_schema["name"] + "-aggregation"
nohits_rule_name =  nohits_schema["name"] + "-aggregation"


if "name" in popular_success:
    print(timestamp() + f"[init_collection] Popular queries collection with name={popular_success['name']} created successfully.")
else:
    print(timestamp() + f"[init_collection] Popular queries collection with name={popular_schema['name']} already exists, no need to create.")
    client.analytics.rules(popular_rule_name).delete()

if "name" in nohits_success:
    print(timestamp() + f"[init_collection] No hits queries collection with name={nohits_success['name']} created successfully.")
else:
    print(timestamp() + f"[init_collection] No hits queries collection with name={nohits_schema['name']} already exists, no need to create.")
    client.analytics.rules(nohits_rule_name).delete()

popular_rule_config = {
  "type": "popular_queries",
  "params": {
    "source": {
      "collections": [search_schema["name"]]
    },
    "destination": {
      "collection": popular_schema["name"]
    },
    "expand_query": False,
    "limit": 1000
  }
}

nohits_rule_config = {
  "type": "nohits_queries",
  "params": {
    "source": {
      "collections": [search_schema["name"]]
    },
    "destination": {
      "collection": nohits_schema["name"]
    },
    "expand_query": False,
    "limit": 1000
  }
}

client.analytics.rules.upsert(popular_rule_name, popular_rule_config)
client.analytics.rules.upsert(nohits_rule_name, nohits_rule_config)
