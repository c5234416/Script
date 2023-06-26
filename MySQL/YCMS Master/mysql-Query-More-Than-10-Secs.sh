#!/bin/bash
# MySQL Query more than 10 Seconds - Sonu
# Thresholds in Numbers warning=3 and critical=4

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
command="select count(*) from information_schema.processlist where info!='null' and time > 5;"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql --defaults-extra-file=/opt/scripts/mysql/mysql.conf  --batch -N --silent -e "$command" | wc -l)

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="mysql_query_morethan10sec{instance=\"$instance\", type=\"query_morethan10sec\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"
