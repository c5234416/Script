#!/bin/bash

PUSHGATEWAY_URL="http://localhost:9108"

# Function to send data to Pushgateway
function push_metrics() {
    local metric_name=$1
    local metric_value=$2
    local metric_labels=$3

    cat <<EOF | curl --data-binary @- $PUSHGATEWAY_URL/metrics/job/mysql_metrics/instance/localhost
# TYPE $metric_name gauge
$metric_name{$metric_labels} $metric_value
EOF
}

# Function to collect and push MySQL data
function collect_and_push_mysql_data() {
    local instance_name=$1
    local mysql_cmd_args="--defaults-extra-file=/usr/lib/check_mk_agent/mysql.cfg"

    # Check if mysqld is running and root password is setup
    local ping_result=$(mysqladmin $mysql_cmd_args $instance_name ping 2>&1)
    if [[ $? -eq 0 ]]; then
        push_metrics "mysql_ping" 1 "instance=\"$instance_name\""
    else
        push_metrics "mysql_ping" 0 "instance=\"$instance_name\""
        return
    fi

    # Get global status and variables
    local status_and_variables=$(mysql $mysql_cmd_args $instance_name -sN -e "show global status; show global variables;")
    push_metrics "mysql_status_and_variables" "$status_and_variables" "instance=\"$instance_name\""

    # Get table schema, data length, and data free
    local capacity=$(mysql $mysql_cmd_args $instance_name -sN -e "SELECT table_schema, sum(data_length + index_length), sum(data_free) FROM information_schema.TABLES GROUP BY table_schema;")
    push_metrics "mysql_capacity" "$capacity" "instance=\"$instance_name\""

    # Get slave status
    local slave_status=$(mysql $mysql_cmd_args $instance_name -s -e "show slave status\G")
    push_metrics "mysql_slave_status" "$slave_status" "instance=\"$instance_name\""
}

# Get MySQL sockets
mysql_sockets=$(grep -oP "socket=\K[^ ]+" /usr/lib/check_mk_agent/mysql.cfg)

# Iterate over each socket and collect/push MySQL data
if [[ -n $mysql_sockets ]]; then
    for socket in $mysql_sockets; do
        collect_and_push_mysql_data "--socket=$socket"
    done
else
    collect_and_push_mysql_data ""
fi
