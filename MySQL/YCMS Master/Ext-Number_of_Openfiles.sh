#!/bin/bash
# Number of Open Files -Sonu
# Threshold - Warning=50000 and Critical=75000


## Static variables & calculations
result=$(cat /proc/sys/fs/file-nr| cut -f1)

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/linux_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="linux_numberof_open_files{instance=\"$instance\", type=\"open_files\"} $result"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"
