#!/bin/bash
# JBOSS Log Error Watching Script - Sonu

# Path to the JBOSS log file
log_file="/opt/jboss/jboss-eap-6.4/domain/servers/ycms-node1/log/server.log"

# Prometheus Gateway configuration
gateway_url="http://localhost:9108"
job_name="java_logs"

# Regex patterns for different types of errors
declare -A error_patterns=(
  ["read_timed_out"]="Read timed out"
  ["new_cluster_view"]="Received new cluster view"
  ["discarded_messages"]="discarded message from non-member"
  ["build_svntag"]="build: SVNTag"
  ["socket_timeout"]="SocketTimeoutException"
  ["javalang_outofmemory"]="java.lang.OutOfMemoryError"
  ["javanet_unknownhost"]="java.net.UnknownHostException"
  ["jdbc_communications"]="jdbc4.CommunicationsException"
  ["unableto_loadschema"]="Unable to load schema"
  ["service_unavailable"]="ServiceUnavailableException"
  ["javanet_connection_refused"]="java.net.ConnectException: Connection refused"
  ["unableto_createdir"]="Unable to create the directory"
  ["unableto_createfile"]="Unable to create the new file"
  ["error_callingapi"]="Error calling the liveness engine API"
  # Add more error patterns as needed
)

# Get the IP address and hostname of the instance
instance_ip=$(hostname -I | awk '{print $1}')
hostname=$(hostname)

# Read the JBOSS log file
log_content=$(cat "$log_file")

# Function to count errors and generate metrics
generate_metrics() {
  local error_type=$1
  local pattern=$2
  local count=$(grep -c "$pattern" <<< "$log_content")
#  echo "# HELP java_log_$error_type Total count of $error_type errors"
#  echo "# TYPE java_log_$error_type gauge"
#  echo "java_log_$error_type $count"
#  echo "java_log_$error_type{instance=\"$instance_ip\"} $count"
   echo "java_log_$error_type{instance=\"$instance_ip\", hostname=\"$hostname\"} $count"

}

# Generate Prometheus metrics
metrics=""
for error_type in "${!error_patterns[@]}"; do
  pattern=${error_patterns[$error_type]}
  metrics+=$(generate_metrics "$error_type" "$pattern")$'\n'
done

# Push metrics to Prometheus Pushgateway
echo -e "$metrics" | curl -X POST -H "Content-Type: text/plain" --data-binary @- "$gateway_url/metrics/job/$job_name"

