import csv
import requests
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders

prometheus_url = "http://10.25.172.67:9090/"
username = "admin"
password = "3ZAEMPLq4r40RXs"
smtp_host = "183.78.1.254"
smtp_port = 25
from_address = "prometheus@yes.my"
to_address = "it_infra_svr@ytlcomms.my"
subject = "PDC Alerts"
message = """
Dear Team,

Please find attached the Prometheus alerts.

Best regards,
Prometheus
"""

# Retrieve alerts from Prometheus
response = requests.get(prometheus_url + "api/v1/alerts", auth=(username, password))
response.raise_for_status()

# Convert alerts to CSV format
alerts_data = response.json()["data"]["alerts"]

csv_data = []

# Extract relevant information from each alert
for alert in alerts_data:
    labels = alert["labels"]
    annotations = alert["annotations"]

    # Create a row for the CSV with relevant alert information
    csv_row = {
        "alertname": labels.get("alertname", ""),
        "severity": labels.get("severity", ""),
        "instance": labels.get("instance", ""),
        "summary": annotations.get("summary", ""),
        "description": annotations.get("description", ""),
    }
    csv_data.append(csv_row)

# Write alerts to a CSV file
output_file = "alerts.csv"
with open(output_file, "w") as file:
    fieldnames = ["alertname", "severity", "instance", "summary", "description"]
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(csv_data)

print("Alerts exported to {} in CSV format.".format(output_file))

# Create the email message
msg = MIMEMultipart()
msg["From"] = from_address
msg["To"] = to_address
msg["Subject"] = subject

# Attach the message body
msg.attach(MIMEText(message, "plain"))

# Attach the alerts.csv file
attachment_filename = "alerts.csv"
attachment_path = "./{}".format(attachment_filename)

attachment = MIMEBase("application", "octet-stream")
attachment.set_payload(open(attachment_path, "rb").read())
encoders.encode_base64(attachment)
attachment.add_header("Content-Disposition", "attachment", filename=attachment_filename)
msg.attach(attachment)

# Send the email
server = smtplib.SMTP(smtp_host, smtp_port)
server.sendmail(from_address, [to_address], msg.as_string())
server.quit()

print("Email sent successfully.")
