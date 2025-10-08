# Update ICOS stations in Typesense collection
# Should be run multiple times each day to ensure index is up to date
# Uses station metadata from icoscp_core
# Note that webforms do not have ETags, so they will be re-checked every time

import typesense, json, yaml
from utilities import timestamp, get_analytics_stations
from icoscp_core.icos import meta

# Read schema from schema.yml to get collection name
with open("schema.yml", "r") as file:
    schema = yaml.safe_load(file)

print(timestamp() + f"[update_stations] Updates started for {schema['name']}.")

stations = meta.list_stations()
stations_info = list()

for station in stations:
    if station.uri == 'http://meta.icos-cp.eu/resources/icos/ES_FA-Lso':
        continue
    station_info = meta.get_station_meta(station)
    if (station_info.specificInfo.stationClass is None
            or station_info.specificInfo.stationClass == "Associated"):
        continue
    stations_info.append(station_info)

def get_https_url(station):
    uri = station.uri[:4] + "s" + station.uri[4:]
    return uri

def get_tc(station_info):
    return station_info.specificInfo.theme.self.label.split(" ")[0]

def get_country(station_info):
    match station_info.countryCode:
        case "BE": return "Belgium"
        #case "CD": return "Democratic Republic of the Congo"
        case "CH": return "Switzerland"
        case "CZ": return "Czech Republic"
        case "DE": return "Germany"
        case "DK": return "Denmark"
        case "ES": return "Spain"
        case "FI": return "Finland"
        case "FR": return "France"
        case "GB": return "United Kingdom"
        #case "GF": return "French Guiana"
        case "GL": return "Greenland (Denmark)"
        case "GR": return "Greece"
        case "HU": return "Hungary"
        case "IE": return "Ireland"
        case "IT": return "Italy"
        case "NL": return "Netherlands"
        case "NO": return "Norway"
        case "SE": return "Sweden"
        case _: return station_info.countryCode

def get_title(station_info):
    return (station_info.org.name + " station (" + station_info.org.self.label +
        ") - " + get_tc(station_info) + " station in " + get_country(station_info))

def get_placeholder_content(station_info):
    return (station_info.org.name + " station (" + station_info.org.self.label +
        ") is an " + get_tc(station_info) + " station in " + get_country(station_info) + ".")

def info_to_document(station_info):
    content = "".join(station_info.org.self.comments)
    doc = {
        "url": get_https_url(station_info.org.self),
        "title": get_title(station_info),
        "content": content,
        "category": "station",
        "num_views_last_year": 0,
    }
    if len(content) == 0:
        if (station_info.org.webpageDetails != None and
                station_info.org.webpageDetails.self.comments != None):
            doc["content"] = station_info.org.webpageDetails.self.comments
        else:
            doc["content"] = get_placeholder_content(station_info)
    return doc

station_documents = list(map(info_to_document, stations_info))

print(timestamp() + f"[update_stations] Prepared docs for {len(station_documents)} stations.")

typesense_api_key = "{{ vault_typesense_api_key }}"
base_url = 'https://meta.icos-cp.eu/'

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

# Convert documents, a list of JSON strings, to objects, and then update each page if necessary
for line in documents:
    doc = json.loads(line)
    # Only use stations
    if doc["category"] != "station":
        continue
    # Add id to proper station_document
    station_doc = [document for document in station_documents if document["url"] == doc["url"]]
    if len(station_doc) == 1:
        station_doc[0]["id"] = doc["id"]

# Add analytics data
url_views = get_analytics_stations()

for doc in station_documents:
    url_path = doc["url"][len(base_url)-1:]
    num_views = 0
    if url_path in url_views:
        num_views = url_views[url_path]
    doc["num_views_last_year"] = num_views

# Update documents in Typesense collection
# using "emplace" to allow for partial updates as well as creations and full updates
updates_success = client.collections[collection_name].documents.import_(station_documents, {'action': 'emplace'})
success_count = sum(d['success'] for d in updates_success)

# Fetch documents again to get accurate total
documents = client.collections[collection_name].documents.export().split("\n")

print(timestamp() + f"[update_stations] Updated documents for {schema['name']}: " + 
      f"{success_count}/{len(updates_success)} updates succeeded, of {len(documents)} total documents.")
