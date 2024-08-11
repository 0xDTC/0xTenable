#!/bin/bash

# Source the secrets file to load the variables
source secrets.txt

# Define the URL to fetch data
TENABLE_API_URL="https://cloud.tenable.com/api/v3/assets/search"

# Define the output CSV file
OUTPUT_FILE="new_hosts2.csv"

# Create a new CSV file with headers
echo -e "IP Address,Host Name" > "$OUTPUT_FILE"

# Initialize pagination variables
PAGE_SIZE=1000
OFFSET=100

# Loop to handle pagination
while true; do
  # Define the payload with pagination
  PAYLOAD=$(cat <<EOF
{
  "filter": {
    "and": [
      {
        "property": "types",
        "operator": "eq",
        "value": "domain_record"
      }
    ]
  },
  "limit": $PAGE_SIZE,
  "offset": $OFFSET
}
EOF
  )

  # Fetch data from Tenable API
  response=$(curl -s -X POST "$TENABLE_API_URL" -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" -H "Content-Type: application/json" -H "Accept: application/json" -d "$PAYLOAD")

  # Debugging: Print the raw response
  echo "Raw response from API: $response"

  # Check if the response is not empty
  if [[ -z "$response" ]]; then
    echo "No response from Tenable API"
    exit 1
  fi

  # Check if the response contains a valid JSON
  if ! echo "$response" | jq . > /dev/null 2>&1; then
    echo "Invalid JSON response"
    exit 1
  fi

  # Parse JSON response and extract IPs and hosts
  new_hosts=$(echo "$response" | jq -r '.assets[] | select(.ipv4 != null or .fqdn != null) | "\(.ipv4)\t\(.fqdn)"')

  # Debugging: Print the parsed hosts
  echo "Parsed hosts: $new_hosts"

  # Check if new hosts are found
  if [[ -z "$new_hosts" ]]; then
    echo "No new hosts found"
    break
  fi

  # Filter out lines that contain empty fields
  filtered_hosts=$(echo "$new_hosts" | awk 'NF' | grep -v '^\[\].*\[\]$')

  # Debugging: Print the filtered hosts
  echo "Filtered hosts: $filtered_hosts"

  # Append filtered hosts to the CSV file
  echo -e "$filtered_hosts" | awk '{print $1","$2}' >> "$OUTPUT_FILE"

  # Increment offset for next page
  OFFSET=$((OFFSET + PAGE_SIZE))

  # Check if the number of results is less than the page size (i.e., last page)
  if [[ $(echo "$response" | jq '.assets | length') -lt $PAGE_SIZE ]]; then
    break
  fi
done

# Inform the user about the completion
echo "New hosts saved to $OUTPUT_FILE"
