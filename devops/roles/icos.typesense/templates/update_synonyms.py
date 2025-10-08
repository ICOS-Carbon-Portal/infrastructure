# Update synonyms in Typesense collection to fully match
# new_synonyms, defined below

import typesense, json, yaml
from utilities import timestamp

# Note all synonyms are multi-way, and any number can be assigned
# One-way synonyms can be created by defining a root, see:
# https://typesense.org/docs/29.0/api/synonyms.html
new_synonyms = [
    # General
    ["station", "stations"],
    ["acronym", "abbreviation"],
    ["observation", "measurement"],
    ["join", "joining"],
    ["Czechia", "Czech Republic"],
    # Abbreviations
    ["14C", "radiocarbon"],
    ["ATC", "Atmosphere Thematic Centre"],
    ["ETC", "Ecosystem Thematic Centre"],
    ["OTC", "Ocean Thematic Centre"],
    ["CAL", "Central Analytic Laboratory"],
    ["CH4", "methane"],
    ["CO2", "carbon dioxide"],
    ["CO", "carbon monoxide"],
    ["N2O", "nitrous oxide"],
    # British-US differences
    ["centre", "center"],
    ["licence", "license"],
    ["recognise", "recognize"],
    ["dialogue", "dialog"],
    ["favour", "favor"],
    ["colour", "color"],
    ["neighbour", "neighbor"],
    ["metre", "meter"],
    ["kilometre", "kilometer"],
    ["centimetre", "centimeter"],
    ["millimetre", "millimeter"],
    ["sulphur", "sulfur"],
]

typesense_api_key = "{{ vault_typesense_api_key }}"
base_url = '{{ base_urls[website] }}'

# Read schema from schema.yml to get collection name
with open("schema.yml", "r") as file:
    schema = yaml.safe_load(file)

print(timestamp() + f"[update_synonyms] Updates started for {schema['name']}.")

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

# .synonyms.retrieve() returns a JSONLines string; split to get one JSON object per entry
synonyms = client.collections[collection_name].synonyms.retrieve()

# Delete existing synonyms, then add new_synonyms
for syn in synonyms["synonyms"]:
    client.collections[collection_name].synonyms[syn["id"]].delete()

# Update documents in Typesense collection
# using "emplace" to allow for partial updates as well as creations and full updates
for synonym in new_synonyms:
    id_name = "-".join(synonym).replace(" ", "-")
    syn_obj = {"synonyms": synonym}
    client.collections[collection_name].synonyms.upsert(id_name, syn_obj)

print(timestamp() + f"[update_synonyms] Updated synonyms for {schema['name']}")
