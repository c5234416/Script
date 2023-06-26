#!/bin/bash

# Prometheus Backup Script - Sonu

# Define variables
PROMETHEUS_URL="http://localhost:9090"
USERNAME="admin"
PASSWORD="3ZAEMPLq4r40RXs"
SNAPSHOT_API_ENDPOINT="${PROMETHEUS_URL}/api/v1/admin/tsdb/snapshot"
BACKUP_DIR="/path/to/backup/directory"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Generate a timestamp for the snapshot
TIMESTAMP=$(date +%Y%m%d%H%M%S)
SNAPSHOT_NAME="snapshot-${TIMESTAMP}"
SNAPSHOT_PATH="${BACKUP_DIR}/${SNAPSHOT_NAME}"

# Trigger snapshot creation using cURL with username and password
SNAPSHOT_RESPONSE=$(curl -s -XPOST --user "${USERNAME}:${PASSWORD}" "${SNAPSHOT_API_ENDPOINT}")

# Extract snapshot details from the API response
SNAPSHOT_NAME=$(echo "${SNAPSHOT_RESPONSE}" | jq -r '.data.name')
SNAPSHOT_PATH=$(echo "${SNAPSHOT_RESPONSE}" | jq -r '.data.path')

# Check if snapshot creation was successful
if [[ $(echo "${SNAPSHOT_RESPONSE}" | jq -r '.status') == "success" ]]; then
  echo "Snapshot created successfully: ${SNAPSHOT_NAME}"

  # Move the snapshot directory to the backup location
  mv "${SNAPSHOT_PATH}" "${BACKUP_DIR}"
  echo "Snapshot moved to backup directory: ${BACKUP_DIR}/${SNAPSHOT_NAME}"
else
  echo "Snapshot creation failed."
  exit 1
fi
