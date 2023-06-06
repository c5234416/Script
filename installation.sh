#!/bin/bash

# This script will install the Push Gateway and add the cronjob for sending metrics to the Prometheus - Sonu

# Extract Push Gateway binary package
cd /home/itops
tar -xvf pushgateway-1.5.0.linux-amd64.tar.gz
cd pushgateway-1.5.0.linux-amd64/
cp pushgateway /usr/local/bin/pushgateway

# Create Push Gateway user
useradd --no-create-home --shell /bin/false pushgateway

# Set ownership of Push Gateway binary
chown pushgateway:pushgateway /usr/local/bin/pushgateway

# Reload systemd daemon
systemctl daemon-reload

# Enable and start Push Gateway service
systemctl enable pushgateway
systemctl start pushgateway

# Create script directory in /opt folder
mkdir -p /opt/scripts
chmod 0755 /opt/scripts

# Copy shell script to PDC servers
cp /home/itops/logwatch.sh /opt/scripts/logwatch.sh
chmod 0755 /opt/scripts/logwatch.sh

# Set up cron job to run script every 15 mins
(crontab -l ; echo "*/15 * * * * /opt/scripts/logwatch.sh") | crontab -
