#!/bin/bash

# AIDE Change Detect Script - Sonu

# Get instance IP address
instance_ip=$(hostname -I | awk '{print $1}')

# AIDE check
/usr/sbin/aide -C >> /tmp/aide.log

# MD5Sum Check
chksum=$(md5sum /var/lib/aide/aide.db.gz | awk '{print $1}')

if [ ! -f "/opt/aide-chksum.lock" ]; then
    echo "aide_chksum{instance_ip=\"$instance_ip\"} $chksum" | curl --data-binary @- http://localhost:9108/metrics/job/aide_chksum
fi

for i in "Added" "Removed" "Changed"; do
    testname="Ext-AIDE-${i}Files"
    metric_name="aide_file_changes_$(echo $i | tr '[:upper:]' '[:lower:]')"

    # Check if there is any output from grep
    grep_output=$(grep "${i} files" /tmp/aide.log | cut -d ":" -f2 | awk '{print $1}' | tr -d '\n')
    if [ -n "$grep_output" ]; then
        testcount=$(echo "$grep_output" | paste -sd+ | bc | tr -d '\n')
    else
        testcount="0"
    fi

    if [ -s "/tmp/aide.log" ]; then
        if grep -q "Looks okay" /tmp/aide.log; then
            echo "$metric_name{type=\"$i\", count=\"0\", instance_ip=\"$instance_ip\"} 0" | curl --data-binary @- http://localhost:9108/metrics/job/aide_file_changes
        else
            if [ "$testcount" -gt 0 ]; then
                echo "$metric_name{type=\"$i\", count=\"1\", instance_ip=\"$instance_ip\"} $testcount" | curl --data-binary @- http://localhost:9108/metrics/job/aide_file_changes
            else
                echo "$metric_name{type=\"$i\", count=\"0\", instance_ip=\"$instance_ip\"} 0" | curl --data-binary @- http://localhost:9108/metrics/job/aide_file_changes
            fi
        fi
    else
        echo "$metric_name{type=\"$i\", count=\"1\", instance_ip=\"$instance_ip\"} 1" | curl --data-binary @- http://localhost:9108/metrics/job/aide_file_changes
    fi
done

rm /tmp/aide.log
