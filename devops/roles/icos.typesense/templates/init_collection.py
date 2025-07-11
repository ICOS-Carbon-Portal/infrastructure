# Create a new Typesense collection based on the schema
import typesense, yaml
from utilities import timestamp

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

creation_success = client.collections.create(schema)
if "name" in creation_success:
    print(timestamp() + f"[init_collection] Schema with name={creation_success["name"]} created successfully.")
else:
    print(timestamp() + f"[init_collection] Collection creation for schema name = {schema["name"]} failed.")
