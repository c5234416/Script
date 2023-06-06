#!/bin/bash

input_file="/root/slowlog.log"
output_file="/root/output.log"
start_marker="# Time: 2023-03-19"
end_marker="# Time:"

export_data=false
lines_to_export=""

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$start_marker"* ]]; then
        export_data=true
    elif [[ "$line" == "$end_marker"* ]]; then
        if [ "$export_data" = true ]; then
            break
        fi
    fi
    if [ "$export_data" = true ]; then
        lines_to_export+="$(echo -e "$line\n")"
    fi
done < "$input_file"

echo -e "$lines_to_export" > "$output_file"
