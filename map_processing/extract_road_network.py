import requests
import json
import os

nodes = [
    # Regional
    {"id": "bhopal_center", "name": "Bhopal Center", "lat": 23.2599, "lon": 77.4126},
    {"id": "indore_center", "name": "Indore Center", "lat": 22.7196, "lon": 75.8577},
    {"id": "dewas", "name": "Dewas Bypass", "lat": 22.9676, "lon": 76.0534},
    {"id": "sehore", "name": "Sehore Town", "lat": 23.2032, "lon": 77.0844},
    {"id": "ashta", "name": "Ashta Corridor", "lat": 23.0210, "lon": 76.7210},
    {"id": "hoshangabad", "name": "Narmadapuram (Hoshangabad)", "lat": 22.7519, "lon": 77.7289},
    {"id": "mandideep", "name": "Mandideep Industrial", "lat": 23.0645, "lon": 77.5186},
    {"id": "obaidullaganj", "name": "Obaidullaganj Junction", "lat": 22.9818, "lon": 77.6253},
    {"id": "vidisha", "name": "Vidisha Bypass", "lat": 23.5251, "lon": 77.8081},
    {"id": "raisen", "name": "Raisen Fort Junction", "lat": 23.3323, "lon": 77.7818},
    {"id": "sagar", "name": "Sagar Highway", "lat": 23.8388, "lon": 78.7378},
    {"id": "ujjain", "name": "Ujjain Mahakal", "lat": 23.1765, "lon": 75.7885},

    # Bhopal Urban
    {"id": "bhopal_station", "name": "Bhopal Central Railway Station", "lat": 23.2672, "lon": 77.4130},
    {"id": "nadra_bus", "name": "Nadra Bus Stand", "lat": 23.2645, "lon": 77.4105},
    {"id": "royal_market", "name": "Royal Market / Peer Gate", "lat": 23.2580, "lon": 77.3995},
    {"id": "vip_road", "name": "VIP Road / Upper Lake", "lat": 23.2680, "lon": 77.3820},
    {"id": "lalghati", "name": "Lalghati Square", "lat": 23.2780, "lon": 77.3620},
    {"id": "bairagarh", "name": "Sant Hirdaram Nagar (Bairagarh)", "lat": 23.2738, "lon": 77.3337},
    {"id": "airport", "name": "Raja Bhoj Airport", "lat": 23.2875, "lon": 77.3378},
    {"id": "gandhi_nagar", "name": "Gandhi Nagar Junction", "lat": 23.2980, "lon": 77.3450},
    {"id": "kamla_park", "name": "Kamla Park / Retghat", "lat": 23.2490, "lon": 77.3980},
    {"id": "polytechnic", "name": "Polytechnic Square", "lat": 23.2425, "lon": 77.3985},
    {"id": "roshanpura", "name": "Roshanpura Square", "lat": 23.2410, "lon": 77.4005},
    {"id": "new_market", "name": "New Market", "lat": 23.2341, "lon": 77.4018},
    {"id": "tt_nagar", "name": "TT Nagar Stadium", "lat": 23.2333, "lon": 77.3960},
    {"id": "mata_mandir", "name": "Mata Mandir Square", "lat": 23.2260, "lon": 77.4020},
    {"id": "manit", "name": "MANIT Bhopal", "lat": 23.2160, "lon": 77.4070},
    {"id": "shivaji_nagar", "name": "Shivaji Nagar / 6 No. Stop", "lat": 23.2320, "lon": 77.4200},
    {"id": "stop_12", "name": "12 No. Stop / E-3 Arera Colony", "lat": 23.2250, "lon": 77.4250},
    {"id": "mp_nagar", "name": "MP Nagar Zone 1", "lat": 23.2332, "lon": 77.4343},
    {"id": "mp_nagar_zone2", "name": "MP Nagar Zone 2 / Jyoti", "lat": 23.2350, "lon": 77.4380},
    {"id": "chetak_bridge", "name": "Chetak Bridge / Kasturba Hospital", "lat": 23.2410, "lon": 77.4420},
    {"id": "isbt", "name": "Kushabhau Thakre ISBT", "lat": 23.2382, "lon": 77.4485},
    {"id": "govindpura", "name": "Govindpura Industrial", "lat": 23.2480, "lon": 77.4560},
    {"id": "bhel_jubilee", "name": "BHEL Jubilee Gate / Indrapuri", "lat": 23.2450, "lon": 77.4750},
    {"id": "piplani", "name": "Piplani Square", "lat": 23.2520, "lon": 77.4850},
    {"id": "ayodhya_bypass", "name": "Ayodhya Bypass / Karond", "lat": 23.2866, "lon": 77.4314},
    {"id": "bhanpur", "name": "Bhanpur Overbridge", "lat": 23.2950, "lon": 77.4200},
    {"id": "rkmp_station", "name": "Rani Kamlapati Railway Station", "lat": 23.2186, "lon": 77.4377},
    {"id": "arera_colony", "name": "Arera Colony (E1-E7)", "lat": 23.2112, "lon": 77.4329},
    {"id": "bittan_market", "name": "Bittan Market / 10 No.", "lat": 23.2150, "lon": 77.4280},
    {"id": "shahpura", "name": "Shahpura Lake / Chunabhatti", "lat": 23.2000, "lon": 77.4167},
    {"id": "kolar_road", "name": "Kolar Road / Sarvdharm", "lat": 23.1829, "lon": 77.4177},
    {"id": "danish_kunj", "name": "Danish Kunj / Kolar", "lat": 23.1650, "lon": 77.4150},
    {"id": "misrod", "name": "Misrod Station / Aashima Mall", "lat": 23.1608, "lon": 77.4683},
    {"id": "bagsewaniya", "name": "Bagsewaniya / AIIMS Bhopal", "lat": 23.1900, "lon": 77.4550},
    {"id": "samardha", "name": "11 Mile Samardha Bypass", "lat": 23.1350, "lon": 77.4950}
]

adjacent_pairs = [
    # Regional Highway Corridors
    ("bhopal_center", "sehore"),
    ("sehore", "ashta"),
    ("ashta", "dewas"),
    ("dewas", "indore_center"),
    ("dewas", "ujjain"),
    ("bhopal_center", "mandideep"),
    ("mandideep", "obaidullaganj"),
    ("obaidullaganj", "hoshangabad"),
    ("bhopal_center", "vidisha"),
    ("vidisha", "sagar"),
    ("bhopal_center", "raisen"),
    ("raisen", "sagar"),

    # West Bhopal Corridor (VIP Road / Bairagarh / Airport)
    ("bhopal_center", "royal_market"),
    ("royal_market", "vip_road"),
    ("vip_road", "lalghati"),
    ("lalghati", "bairagarh"),
    ("bairagarh", "airport"),
    ("airport", "gandhi_nagar"),
    ("bairagarh", "sehore"),
    ("lalghati", "ayodhya_bypass"),

    # Old City to Central Corridor
    ("bhopal_center", "bhopal_station"),
    ("bhopal_station", "nadra_bus"),
    ("nadra_bus", "royal_market"),
    ("royal_market", "kamla_park"),
    ("kamla_park", "polytechnic"),
    ("polytechnic", "roshanpura"),
    ("roshanpura", "new_market"),
    ("new_market", "tt_nagar"),
    ("new_market", "mata_mandir"),
    ("mata_mandir", "manit"),
    ("manit", "shahpura"),

    # Link Roads & Central Arteries
    ("roshanpura", "shivaji_nagar"),
    ("shivaji_nagar", "stop_12"),
    ("stop_12", "bittan_market"),
    ("bittan_market", "arera_colony"),
    ("roshanpura", "mp_nagar"),
    ("shivaji_nagar", "mp_nagar"),
    ("mp_nagar", "mp_nagar_zone2"),
    ("mp_nagar_zone2", "chetak_bridge"),
    ("chetak_bridge", "isbt"),
    ("isbt", "govindpura"),
    ("govindpura", "bhel_jubilee"),
    ("bhel_jubilee", "piplani"),

    # North Corridor (Ayodhya Bypass)
    ("bhopal_station", "bhanpur"),
    ("bhanpur", "ayodhya_bypass"),
    ("ayodhya_bypass", "isbt"),
    ("ayodhya_bypass", "piplani"),

    # South Corridor (Hoshangabad Road & RKMP)
    ("mp_nagar", "rkmp_station"),
    ("rkmp_station", "arera_colony"),
    ("arera_colony", "bittan_market"),
    ("arera_colony", "shahpura"),
    ("shahpura", "kolar_road"),
    ("kolar_road", "danish_kunj"),
    ("rkmp_station", "bagsewaniya"),
    ("bagsewaniya", "misrod"),
    ("misrod", "samardha"),
    ("samardha", "mandideep"),
    ("danish_kunj", "samardha")
]

edges = []
nodes_dict = {n["id"]: n for n in nodes}

print(f"Querying Valhalla for {len(adjacent_pairs)} road corridors...")

for idx, (src_id, dst_id) in enumerate(adjacent_pairs):
    src = nodes_dict[src_id]
    dst = nodes_dict[dst_id]
    req = {
        "locations": [
            {"lat": src["lat"], "lon": src["lon"]},
            {"lat": dst["lat"], "lon": dst["lon"]}
        ],
        "costing": "auto",
        "directions_options": {"units": "kilometers"}
    }
    try:
        res = requests.post("http://localhost:8002/route", json=req, timeout=5)
        if res.status_code == 200:
            data = res.json()
            trip = data.get("trip", {})
            summary = trip.get("summary", {})
            legs = trip.get("legs", [])
            if legs:
                leg = legs[0]
                shape = leg.get("shape", "")
                maneuvers = [
                    {"instruction": m.get("instruction", ""), "length": m.get("length", 0)}
                    for m in leg.get("maneuvers", [])
                ]
                dist_km = round(summary.get("length", 0.0), 2)
                time_mins = round(summary.get("time", 0.0) / 60.0, 1)

                edges.append({
                    "from": src_id,
                    "to": dst_id,
                    "distanceKm": dist_km,
                    "durationMins": time_mins,
                    "shape": shape,
                    "maneuvers": maneuvers
                })
                # Query reverse for one-way accuracy
                req_rev = {
                    "locations": [
                        {"lat": dst["lat"], "lon": dst["lon"]},
                        {"lat": src["lat"], "lon": src["lon"]}
                    ],
                    "costing": "auto",
                    "directions_options": {"units": "kilometers"}
                }
                res_rev = requests.post("http://localhost:8002/route", json=req_rev, timeout=5)
                if res_rev.status_code == 200:
                    data_rev = res_rev.json()
                    leg_rev = data_rev.get("trip", {}).get("legs", [{}])[0]
                    edges.append({
                        "from": dst_id,
                        "to": src_id,
                        "distanceKm": round(data_rev.get("trip", {}).get("summary", {}).get("length", dist_km), 2),
                        "durationMins": round(data_rev.get("trip", {}).get("summary", {}).get("time", 0) / 60.0, 1),
                        "shape": leg_rev.get("shape", shape),
                        "maneuvers": [
                            {"instruction": m.get("instruction", ""), "length": m.get("length", 0)}
                            for m in leg_rev.get("maneuvers", [])
                        ]
                    })
                print(f"[{idx+1}/{len(adjacent_pairs)}] {src['name']} <-> {dst['name']}: {dist_km} km ({time_mins} min)")
    except Exception as e:
        print(f"Error {src_id}->{dst_id}: {e}")

out_data = {
    "version": "1.0",
    "region": "Central India & Bhopal Arterial Road Network",
    "nodes": nodes,
    "edges": edges
}

os.makedirs("assets/routing", exist_ok=True)
with open("assets/routing/road_network.json", "w", encoding="utf-8") as f:
    json.dump(out_data, f, indent=2)

print(f"\nDone! Extracted {len(nodes)} nodes and {len(edges)} directed road edges to assets/routing/road_network.json")
