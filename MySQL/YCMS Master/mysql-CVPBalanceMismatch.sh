#!/bin/bash
# MySQL CVP Balance Mismatch -Sonu
# Threshold - Warning=1 and Critical=2

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
command='SELECT CA.`ACCOUNT_ID` AS "Account Id", rpt.`account_code` AS "Company Code", rpt.`account_name` AS "Company Name", NOW() AS "Opening Balance Date", CA.`BALANCE` AS "Opening Balance", rpt.`balance_date` AS "Closing Balance Date", rpt.`balance` AS "Closing Balance" FROM ycms.CVP_ACCOUNT CA, ycms.`rpt_account_daily_balance_mv` rpt WHERE CA.`ACCOUNT_ID` = rpt.`account_id` AND CA.`BALANCE` != rpt.`balance` AND rpt.`balance_date` = DATE(DATE_SUB(NOW(), INTERVAL 1 DAY));'

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql --defaults-extra-file=/opt/scripts/mysql/mysql.conf --batch -N --silent -e "$command" | wc -l)

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="mysql_cvpbalance_mismatch{instance=\"$instance\", type=\"cvpbalance_mismatch\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"