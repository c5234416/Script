#!/bin/bash
# MySQL Concurrent Connections -Sonu
# Threshold -
# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
command="select count(*) from information_schema.processlist where Command!='Sleep';"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql --defaults-extra-file=/opt/scripts/mysql/mysql.conf --batch --silent --skip-column-names -e "$command")

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="mysql_concurrent_connections{instance=\"$instance\", type=\"concurrent_connections\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"
