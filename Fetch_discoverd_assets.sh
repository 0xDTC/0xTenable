#!/bin/bash

# Source the secrets file to load the variables
source secrets.txt

# Define the URL to fetch data
TENABLE_API_URL="https://cloud.tenable.com/api/v3/assets/search"

# Define the output CSV file
OUTPUT_FILE="unscanned_host_and_ips.csv"

# Define the page size (maximum 1000 items per page)
PAGE_SIZE=1000

# Function to fetch data from Tenable API
fetch_data() {
  local offset="$1"

  # Add here by checking in inspect network search for "search api"
  curl -s -X POST "$TENABLE_API_URL" -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" -H "Content-Type: application/json" -H "Accept: */*" -H "x-cookie: token= $XCOOKIE" --data-raw "{
      \"filter\": {
        \"and\": [
          {
            \"property\": \"types\",
            \"operator\": \"eq\",
            \"value\": \"domain_record\"
          }
        ]
      },
      \"limit\": $PAGE_SIZE,
      \"sort\": [
        {
          \"last_observed\": \"desc\"
        }
      ],
      \"offset\": $offset
    }"
}

# Initialize variables
offset=0
all_hosts=""

# Fetch the total number of items
total_items=$(fetch_data $offset | jq -r '.pagination.total')

# Loop to fetch all pages
while [[ $offset -lt $total_items ]]; do
  response=$(fetch_data $offset)
  echo "Fetching page with offset $offset..."

  # Debugging: Print the raw API response
  echo "Raw API response: $response"

  # Parse JSON response and handle possible null or empty fields
  new_hosts=$(echo "$response" | jq -r '
    .assets[] |
    if (.ipv4_addresses != null and .ipv4_addresses != [] and .fqdn != null) then
      .ipv4_addresses[] + "\t" + .fqdn
    elif (.ipv6_addresses != null and .ipv6_addresses != [] and .fqdn != null) then
      .ipv6_addresses[] + "\t" + .fqdn
    else
      empty
    end
  ')

  # Debugging: Print the parsed hosts
  echo "Parsed hosts: $new_hosts"

  # Check if new hosts are found, if not break the loop
  if [[ -z "$new_hosts" ]]; then
    echo "No more new hosts found."
    break
  fi

  # Accumulate the results
  all_hosts="$all_hosts"$'\n'"$new_hosts"

  # Increment offset by page size
  offset=$((offset + PAGE_SIZE))
done

# Check if there were any hosts found
if [[ -z "$all_hosts" ]]; then
  echo "No hosts found."
  exit 0
fi

# Filter out lines that contain empty fields
filtered_hosts=$(echo "$all_hosts" | awk 'NF' | grep -v '^\[\].*\[\]$')

# Create a new CSV file with headers
echo -e "IP Address\tFQDN" > "$OUTPUT_FILE"

# Append the filtered hosts to the CSV file
echo -e "$filtered_hosts" >> "$OUTPUT_FILE"

echo "Data successfully written to $OUTPUT_FILE"
