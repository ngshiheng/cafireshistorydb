import json
import sqlite3
import urllib.request

url = "https://www.fire.ca.gov/api/sitecore/Incident/GetFiresForMap?showFeatured=false"
headers = {
    "User-Agent": "ca-fires-history-db (me@jerrynsh.com)",
}

print("Fetching data from API...")
req = urllib.request.Request(url, headers=headers)
with urllib.request.urlopen(req) as response:
    json_data = response.read().decode("utf-8")

data = json.loads(json_data)
print(f"Received data for {len(data)} fire incidents")

with sqlite3.connect("data/fires.db") as conn:
    cursor = conn.cursor()

    print("Creating incidents table if it doesn't exist")
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS incidents (
        UniqueId TEXT PRIMARY KEY,
        Name TEXT,
        Updated TEXT,
        Started TEXT,
        AdminUnit TEXT,
        County TEXT,
        Location TEXT,
        AcresBurned REAL,
        PercentContained REAL,
        Longitude REAL,
        Latitude REAL,
        Url TEXT,
        IsActive INTEGER
    )
    """)

    new_or_updated_count = 0
    for item in data:
        cursor.execute(
            """
            INSERT OR REPLACE INTO incidents (
                UniqueId, Name, Updated, Started, AdminUnit, County, Location,
                AcresBurned, PercentContained, Longitude, Latitude, Url, IsActive
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                item["UniqueId"],
                item["Name"],
                item["Updated"],
                item["Started"],
                item["AdminUnit"],
                item["County"],
                item["Location"],
                item["AcresBurned"],
                item["PercentContained"],
                item["Longitude"],
                item["Latitude"],
                item["Url"],
                1 if item["IsActive"] else 0,
            ),
        )
        if cursor.rowcount > 0:
            new_or_updated_count += 1
            print(f"Inserted or updated: {item['Name']} (ID: {item['UniqueId']})")

    print(f"Total rows inserted or updated: {new_or_updated_count}")

print("Operation completed")
