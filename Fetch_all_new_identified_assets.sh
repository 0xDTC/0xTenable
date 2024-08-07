#!/bin/bash

# Source the secrets file to load the variables
source secrets.txt

# Define the URL to fetch data
TENABLE_API_URL="https://cloud.tenable.com/assets"

# Define the output CSV file
OUTPUT_FILE="new_hosts.csv"

# Fetch data from Tenable API
response=$(curl -s -X GET "$TENABLE_API_URL" -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" -H "Accept: application/json")

# Check if the response is not empty
if [[ -z "$response" ]]; then
  echo "No response from Tenable API"
  exit 1
fi

# Parse JSON response and extract IPs and hosts
new_hosts=$(echo "$response" | jq -r '.assets[] | select(.ipv4 != null and .fqdn != null) | "\(.ipv4)\t\(.fqdn)"')

# Check if new hosts are found
if [[ -z "$new_hosts" ]]; then
  echo "No new hosts found"
  exit 0
fi

# Filter out lines that contain empty fields
filtered_hosts=$(echo "$new_hosts" | awk 'NF' | grep -v '^\[\].*\[\]$')

# Create a new CSV file with headers
echo -e "IP Address,Host Name\n$filtered_hosts" > "$OUTPUT_FILE"

echo "New hosts have been saved to $OUTPUT_FILE"
