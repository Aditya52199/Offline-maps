import requests

url = "http://localhost:8002/route"
payload = {
    "locations": [
        {"lat": 23.2599, "lon": 77.4126, "type": "break"},  # Bhopal
        {"lat": 22.7196, "lon": 75.8577, "type": "break"}   # Indore
    ],
    "costing": "auto",
    "directions_options": {"units": "kilometers"}
}

response = requests.post(url, json=payload)
data = response.json()

if "trip" in data:
    summary = data["trip"]["summary"]
    print("=== Route Found! ===")
    print(f"Distance: {summary['length']} km")
    print(f"Duration: {round(summary['time'] / 60, 1)} minutes")
    
    print("\n--- Maneuvers ---")
    for step in data["trip"]["legs"][0]["maneuvers"]:
        print(f"-> {step['instruction']} ({step['length']} km)")
else:
    print("Error:", data)
