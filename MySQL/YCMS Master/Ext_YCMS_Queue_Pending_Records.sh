#!/bin/bash
# MySQL YCMS Queue Pending Records -Sonu
# Threshold - warning=350 and critical=400

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
command="use ytlc_queue_ycms; SELECT COUNT(*) FROM QUEUE_DATA WHERE PROCESS_STATUS='P' AND SOURCE NOT IN ('FrogStore','MOE','NSMI','YOS','SCM','YMCABULK') AND PROCESS_DELAY='0';"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql -u$username -p$password --batch --silent -e "$command" 2>/dev/null)

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="mysql_ycmsqueue_pendingrecords{instance=\"$instance\", type=\"ycmsqueue_pendingrecords\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"
