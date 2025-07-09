# Create a new Typesense collection based on the schema
import typesense, yaml

typesense_api_key = "{{ vault_typesense_api_key }}"

# Read schema from schema.yml
with open("schema.yml", "r") as file:
    schema = yaml.safe_load(file)

client = typesense.Client({
  'nodes': [{
    'host': 'localhost',
    'port': '{{ typesense_port }}',
    'protocol': 'http'
  }],
  'api_key': typesense_api_key,
  'connection_timeout_seconds': 600
})

try:
  client.collections[schema["name"]].delete()
except:
  pass

client.collections.create(schema)
