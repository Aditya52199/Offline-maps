import urllib.request
import urllib.parse
import json

sparql = """
SELECT ?item ?itemLabel ?lat ?lon ?categoryLabel WHERE {
  ?item wdt:P131* wd:Q1747;
        wdt:P625 ?coord.
  ?item p:P625 ?coordStatement.
  ?coordStatement psv:P625 ?coordNode.
  ?coordNode wikibase:geoLatitude ?lat;
             wikibase:geoLongitude ?lon.
  OPTIONAL { ?item wdt:P31 ?category. }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}
LIMIT 300
"""

url = 'https://query.wikidata.org/sparql?query=' + urllib.parse.quote(sparql) + '&format=json'
req = urllib.request.Request(url, headers={'User-Agent': 'OfflineGpsApp/1.0 (Bhopal Mapping Project)'})

try:
    with urllib.request.urlopen(req, timeout=25) as resp:
        data = json.loads(resp.read().decode())
        bindings = data['results']['bindings']
        print(f"Wikidata returned: {len(bindings)} locations!")
        with open("map_processing/data/wikidata_bhopal.json", "w", encoding="utf-8") as f:
            json.dump(bindings, f, indent=2, ensure_ascii=False)
except Exception as e:
    print(f"Error: {e}")
