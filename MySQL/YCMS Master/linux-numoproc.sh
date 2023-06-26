#!/bin/bash
# Linux Number of Processes -Sonu
# Threshold - Warning=750 and Critical=1500


## Static variables & calculations
result=$(ps -A --no-headers | wc -l)
result1=$(ps -AL --no-headers | wc -l)

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/linux_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="linux_numberof_process{instance=\"$instance\", type=\"numberof_process\"} $result"
metrics_data1="linux_numberof_processthread{instance=\"$instance\", type=\"numberof_process\"} $result1"
# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"
echo -e "$metrics_data1" | curl -X POST --data-binary @- "$pushgateway_url"