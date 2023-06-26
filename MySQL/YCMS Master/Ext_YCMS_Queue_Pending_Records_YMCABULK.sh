#!/bin/bash
# MySQL YCMS Queue Pending Records YMCA Bulk -Sonu
# Threshold - warning=170 and critical=190

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
command="SELECT   a.\`PROCESS_STATUS\`,  COUNT(*) FROM  ytlc_queue_ycms.\`QUEUE_DATA\` a WHERE DATE(a.\`CREATED_DATE\`) = CURRENT_DATE()   AND a.\`SOURCE\` =  'YMCABULK' and a.PROCESS_STATUS='P' and a.PROCESS_DELAY='0' GROUP BY 1 ;"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql -u$username -p$password --batch --silent -e "$command" 2>/dev/null)

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="mysql_ycmsqueue_pendingrecordsymcabulk{instance=\"$instance\", type=\"ycmsqueue_pendingrecordsymcabulk\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"
