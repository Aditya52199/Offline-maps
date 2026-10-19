import urllib.request
import urllib.parse
import json

bbox = "23.15,77.28,23.33,77.52"

# Query key categories in Bhopal
query = f"""[out:json][timeout:30];
(
  node["amenity"~"hospital|clinic|pharmacy|bank|atm|police|fuel|restaurant|cafe|fast_food|college|university|school|bus_station"]({bbox});
  node["tourism"~"attraction|hotel|museum|viewpoint|zoo"]({bbox});
  node["historic"]({bbox});
  node["railway"="station"]({bbox});
  node["shop"~"supermarket|mall|department_store"]({bbox});
  node["leisure"~"park|garden|sports_centre|stadium"]({bbox});
  node["place"~"suburb|neighbourhood|quarter"]({bbox});
);
out tags center;"""

url = "https://overpass-api.de/api/interpreter?data=" + urllib.parse.quote(query)
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json',
}

print("Querying Overpass...")
req = urllib.request.Request(url, headers=headers)
try:
    with urllib.request.urlopen(req, timeout=35) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        elements = data.get('elements', [])
        print(f"Total elements retrieved: {len(elements)}")
        with open("map_processing/data/bhopal_raw_pois.json", "w", encoding="utf-8") as f:
            json.dump(elements, f, indent=2, ensure_ascii=False)
except Exception as e:
    print(f"Failed: {e}")
