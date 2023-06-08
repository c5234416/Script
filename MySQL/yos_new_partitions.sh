#!/bin/bash
#  eKyc New Partitions Verification - Sonu

## Changeable variables. Change only variables inside here (!!)
# Thresholds in Numbers
warning=0
critical=0

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
testname=eKyc-Missing-Partition-DBTeam
command="SELECT COUNT(1) CNT FROM information_schema.partitions WHERE table_name='TXN_EKYC_ASSET' AND PARTITION_DESCRIPTION=TO_DAYS(DATE_ADD(CURRENT_DATE, INTERVAL 9 DAY)) AND TABLE_SCHEMA='ytlc_ekyc';"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql --defaults-extra-file=/usr/lib/check_mk_agent/mysql.conf --batch -N --silent -e "$command" | awk '{print $1}')

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

echo "$status mysql_custom_mysql_ekycmissing_partition sqlresult=$woot;$warning;$critical;0 SQL Output is $woot (Warning $warning, Critical $critical)"

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="# TYPE mysql_ekycmissing_partition gauge
mysql_ekycmissing_partition{instance=\"$instance\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"

