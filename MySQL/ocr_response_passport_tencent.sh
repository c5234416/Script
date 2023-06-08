#!/bin/bash
# Passport OCR Response slowness from Tencent - Sonu

## Changeable variables. Change only variables inside here (!!)
# Thresholds in Numbers
warning=4
critical=4

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
testname=OCRResponseTencentPassport-PortalTeam
command="SELECT COUNT(1) FROM ytlc_ekyc.TXN_TENCENT_PASSPORT_RES_INFO WHERE created_date BETWEEN (NOW() - INTERVAL 15 MINUTE) AND NOW() AND TIMETAKEN_MS>=10000;"

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

echo "$status mysql_custom_mysql_ocrresponse_tencentpassport sqlresult=$woot;$warning;$critical;0 SQL Output is $woot (Warning $warning, Critical $critical)"

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="# TYPE mysql_ocrresponse_tencentpassport gauge
mysql_ocrresponse_tencentpassport{instance=\"$instance\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"

