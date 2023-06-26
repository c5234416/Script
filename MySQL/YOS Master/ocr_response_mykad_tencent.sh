#!/bin/bash
# MYKAD OCR Response slowness from Tencent - Sonu
# Thresholds in Numbers warning=4 critical=4

# MySQL Credentials
username=nagiosuser
password="Xwefr&mce(8Na12"

# MySQL Command. Remember testname should not contain any space
command="SELECT COUNT(1) FROM ytlc_ekyc.TXN_TENCENT_MYKAD_RES_INFO WHERE created_date BETWEEN (NOW() - INTERVAL 15 MINUTE) AND NOW() AND TIMETAKEN_MS>=10000;"

## Static variables & calculations
mysql=$(which mysql)
woot=$($mysql --defaults-extra-file=/usr/lib/check_mk_agent/mysql.conf --batch -N --silent -e "$command" | awk '{print $1}')

# Push metrics to Prometheus Pushgateway
pushgateway_url="http://localhost:9108/metrics/job/mysql_custom"
instance=$(hostname -I | awk '{print $1}') # Set instance IP as the script is running on the same machine

# Format the metrics data
metrics_data="mysql_mykadocr_responsetencent{instance=\"$instance\", type=\"mykadocr_responsetencent\"} $woot"

# Push the metrics using cURL
echo -e "$metrics_data" | curl -X POST --data-binary @- "$pushgateway_url"

