#!/bin/bash
# MySQL Row Count for JCR SITEM - Sonu
# Thresholds in Numbers warning=13000000 and critical=14000000

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
command="select TABLE_ROWS from information_schema.TABLES where TABLE_SCHEMA='gateinjcr_sp' and TABLE_NAME='JCR_SITEM';"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql -u$username -p$password --batch --silent -e "$command")

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="mysql_rowcount_jcrsitem{instance=\"$instance\", type=\"rowcount_jcrsitem\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"