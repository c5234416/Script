#!/bin/bash
# MySQL Slow Query Count - Sonu

## Changeable variables. Change only variables inside here (!!)
# Thresholds in Numbers
warning=10
critical=20

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
testname=Slow-Query-Count
command="select count(*) from information_schema.processlist where info!='null' and time > 10;"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql -u$username -p$password --batch --silent -e "$command")


# Thresholds going downwards or upwards?. Comment/Uncomment whichever is necessary
#how=lt # Downwards - Example: Warning 30%, Critical 20%
how=gt # Upwards - Example: Warning 80%, Critical 90%

## Functions

if [ $woot -$how $critical ] ; then
        status=2
elif [ $woot -$how $warning ] ; then
        status=1
else
        status=0
fi

## Output

echo "$status mysql_custom_mysql_slowquery_count sqlresult=$woot;$warning;$critical;0 SQL Output is $woot (Warning $warning, Critical $critical)"

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="# TYPE mysql_slowquery_count gauge
mysql_slowquery_count{instance=\"$instance\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"

