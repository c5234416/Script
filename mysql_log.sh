#!/bin/bash
# MySQL Log Error Watching Script - Sonu

# Path to the MySQL log file
log_file="/var/log/mysqld.log"

# Prometheus Gateway configuration
gateway_url="http://localhost:9108"
job_name="mysql_logs"

# Regex patterns for different types of errors
declare -A error_patterns=(
  ["connection_error"]="ERROR: Can't connect to MySQL server"
  ["query_error"]="ERROR: You have an error in your SQL syntax"
  ["auth_error"]="Access denied for user"
  ["error_connecting_to_master"]="MY-010584"
  ["error_reconnecting_to_master"]="error reconnecting to master"
  ["plugin_group_replication_reported"]="Shutting down an outgoing connection"
  ["sql_slave_thread_aborted"]="Error running query, slave SQL thread aborted"
  # Add more error patterns as needed
)

# Get the IP address and hostname of the instance
instance_ip=$(hostname -I | awk '{print $1}')
hostname=$(hostname)

# Read the MySQL log file
log_content=$(cat "$log_file")

# Function to count errors and generate metrics
generate_metrics() {
  local error_type=$1
  local pattern=$2
  local count=$(grep -c "$pattern" <<< "$log_content")
#  echo "# HELP mysql_log_$error_type Total count of $error_type errors"
#  echo "# TYPE mysql_log_$error_type gauge"
#  echo "mysql_log_$error_type $count"
#  echo "mysql_log_$error_type{instance=\"$instance_ip\"} $count"
   echo "mysql_log_$error_type{instance=\"$instance_ip\", hostname=\"$hostname\"} $count"

}

# Generate Prometheus metrics
metrics=""
for error_type in "${!error_patterns[@]}"; do
  pattern=${error_patterns[$error_type]}
  metrics+=$(generate_metrics "$error_type" "$pattern")$'\n'
done

# Push metrics to Prometheus Pushgateway
echo -e "$metrics" | curl -X POST -H "Content-Type: text/plain" --data-binary @- "$gateway_url/metrics/job/$job_name"

