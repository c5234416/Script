#!/bin/bash
## Linux Memory Usage Script for Prometheus Pushgateway

## Changeable variables. Change only variables inside here (!!)
# Thresholds in percentage
warning=30
critical=20

## Checks if bc is installed or not
command -v bc >/dev/null 2>&1 || { echo >&2 "Package bc is not installed and is used to do calculations. Please install it."; exit 1; }

# Extract memory information
if free | grep -q available; then
    # RHEL-7 or compatible
    used=$(free | awk '/^Mem:/ {print $3}')
    usedmb=$(free -m | awk '/^Mem:/ {print $3}')
    total=$(free | awk '/^Mem:/ {print $2}')
    totalmb=$(free -m | awk '/^Mem:/ {print $2}')
    free=$(echo "$total - $used" | bc)
    freemb=$(echo "$totalmb - $usedmb" | bc)
else
    # Non-RHEL7 or compatible
    used=$(free | awk '/^Mem:/ {print $3}')
    usedmb=$(free -m | awk '/^Mem:/ {print $3}')
    free=$(free | awk '/^Mem:/ {print $4}')
    freemb=$(free -m | awk '/^Mem:/ {print $4}')
    total=$(free | awk '/^Mem:/ {print $2}')
    totalmb=$(free -m | awk '/^Mem:/ {print $2}')
fi

# Calculate percentages and thresholds
usedperc=$(echo "scale=2; ($used / $total) * 100" | bc -l)
freeperc=$(echo "scale=2; ($free / $total) * 100" | bc -l)


# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/linux_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="linux_memory_usedperc{instance=\"$instance\", type=\"memory_usedper\"} $usedperc"
metrics_data1="linux_memory_freeperc{instance=\"$instance\", type=\"memory_freeperc\"} $freeperc"
# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"
echo -e "$metrics_data1" | curl -X POST --data-binary @- "$pushgateway_url"

#echo "$freemb MB free out of $totalmb MB. Used is $usedmb MB. Percentage Used/Free ($usedperc%/$freeperc%)"
