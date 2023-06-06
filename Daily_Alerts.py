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
linux_to_address = "it_infra_svr@ytlcomms.my"
windows_to_address = "it_infra_win@ytlcomms.my"
mysql_to_address = "it_infra_db@ytlcomms.my"
additional_recipients = ["sonu.rajan@ytlcomms.my", "ramarao.penigalapati@ytlcomms.my"]
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

# Filter alerts not starting with "Windows" or "Mysql"
input_file = "alerts.csv"
linux_output_file = "Linux_Alerts.csv"
windows_output_file = "Windows_Alerts.csv"
mysql_output_file = "MySQL_Alerts.csv"

# Filter alerts for Linux
filtered_linux_data = []
with open(input_file, "r") as file:
    reader = csv.reader(file)
    header = next(reader)  # Read and store the header row
    for row in reader:
        if not row[0].startswith(("Windows", "Mysql")):
            filtered_linux_data.append(row)

# Write filtered Linux alerts to a new CSV file
with open(linux_output_file, "w") as file:
    writer = csv.writer(file)
    writer.writerow(header)  # Write the header row
    writer.writerows(filtered_linux_data)

print("Filtered Linux alerts exported to {}.".format(linux_output_file))

# Filter alerts for Windows
filtered_windows_data = []
with open(input_file, "r") as file:
    reader = csv.reader(file)
    header = next(reader)  # Read and store the header row
    for row in reader:
        if row[0].startswith("Windows"):
            filtered_windows_data.append(row)

# Write filtered Windows alerts to a new CSV file
with open(windows_output_file, "w") as file:
    writer = csv.writer(file)
    writer.writerow(header)  # Write the header row
    writer.writerows(filtered_windows_data)

print("Filtered Windows alerts exported to {}.".format(windows_output_file))

# Filter alerts for MySQL
filtered_mysql_data = []
with open(input_file, "r") as file:
    reader = csv.reader(file)
    header = next(reader)  # Read and store the header row
    for row in reader:
        if row[0].startswith("Mysql"):
            filtered_mysql_data.append(row)

# Write filtered MySQL alerts to a new CSV file
with open(mysql_output_file, "w") as file:
    writer = csv.writer(file)
    writer.writerow(header)  # Write the header row
    writer.writerows(filtered_mysql_data)

print("Filtered MySQL alerts exported to {}.".format(mysql_output_file))

# Function to send email with attachment
def send_email_with_attachment(from_address, to_address, subject, message, attachment_path):
    # Create the email message
    msg = MIMEMultipart()
    msg["From"] = from_address
    msg["To"] = to_address
    msg["Subject"] = subject

    # Attach the message body
    msg.attach(MIMEText(message, "plain"))

    # Attach the CSV file
    attachment = MIMEBase("application", "octet-stream")
    attachment.set_payload(open(attachment_path, "rb").read())
    encoders.encode_base64(attachment)
    attachment.add_header(
        "Content-Disposition", "attachment", filename=attachment_path.split("/")[-1]
    )
    msg.attach(attachment)

    # Send the email
    server = smtplib.SMTP(smtp_host, smtp_port)
    server.sendmail(from_address, to_address, msg.as_string())
    server.quit()

# Send email with Linux alerts CSV attachment
send_email_with_attachment(from_address, linux_to_address, subject, message, linux_output_file)
print("Email sent successfully to {}.".format(linux_to_address))

# Send email with Windows alerts CSV attachment
send_email_with_attachment(from_address, windows_to_address, subject, message, windows_output_file)
print("Email sent successfully to {}.".format(windows_to_address))

# Send email with MySQL alerts CSV attachment
send_email_with_attachment(from_address, mysql_to_address, subject, message, mysql_output_file)
print("Email sent successfully to {}.".format(mysql_to_address))

# Send email with original alerts CSV attachment to additional recipients
for recipient in additional_recipients:
    send_email_with_attachment(from_address, recipient, subject, message, output_file)
    print("Email sent successfully to {}.".format(recipient))
