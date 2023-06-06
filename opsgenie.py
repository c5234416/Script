import csv
import json
import requests

api_key = "8456b051-1736-4998-bfe9-572f7c578a73"
offset = 0
limit = 100
sort = "createdAt"
order = "desc"

# Set up the API endpoint URL
url = "https://api.opsgenie.com/v2/alerts"

# Set the request headers
headers = {
    "Authorization": f"GenieKey {api_key}",
    "Content-Type": "application/json"
}

# Set the request parameters
params = {
    "offset": offset,
    "limit": limit,
    "sort": sort,
    "order": order
}

# Make the initial request to get the alerts
response = requests.get(url, headers=headers, params=params)
data = response.json()

# Retrieve all alerts
alerts = data.get("data", [])

# Paginate through the alerts if there are more than the initial request limit
while data.get("paging", {}).get("next") is not None:
    offset += limit
    params["offset"] = offset
    response = requests.get(url, headers=headers, params=params)
    data = response.json()
    alerts.extend(data.get("data", []))

# Save alerts data to a JSON file if alerts list is not empty
if alerts:
    json_file_path = "alerts.json"
    with open(json_file_path, mode="w") as file:
        json.dump(alerts, file, indent=4)

    print(f"Alerts exported to {json_file_path}")
else:
    print("No alerts found.")

# Define the CSV file path
csv_file_path = "alerts_extracted.csv"

# List of required columns
required_columns = [
    "id", "message", "status", "acknowledged", "count", "createdAt", "updatedAt",
    "source", "owner", "priority", "teams"
]

# Extract data and write to CSV file
with open(csv_file_path, mode="w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(required_columns)

    for alert in alerts:
        teams = alert.get("teams")
        if teams:
            team_ids = [team.get("id") for team in teams]
            teams = ", ".join(team_ids)
        else:
            teams = ""
        row_data = [
            alert.get("id"), alert.get("message"), alert.get("status"),
            alert.get("acknowledged"), alert.get("count"), alert.get("createdAt"),
            alert.get("updatedAt"), alert.get("source"), alert.get("owner"),
            alert.get("priority"), teams
        ]
        writer.writerow(row_data)

print(f"Alerts extracted to {csv_file_path}")
