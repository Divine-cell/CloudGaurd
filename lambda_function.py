import json
import os
import urllib3

SLACK_WEBHOOK = os.environ['SLACK_WEBHOOK_URL']
http = urllib3.PoolManager()
def lambda_handler(event, context):
    for record in event.get("detail", {}).get("findings", []):
        sev_obj = record.get("Severity", {})
        severity = sev_obj.get("Label") or sev_obj.get("label") or "UNKNOWN"

        # Extract resource ID safely
        resources = "UNKNOWN"
        if "Resources" in record and len(record["Resources"]) > 0:
            resources = record["Resources"][0].get("Id", "UNKNOWN")

        description = record.get("Description", "No description provided")

        # SEND ALERT only for MEDIUM, HIGH, CRITICAL
        if severity in ["MEDIUM","HIGH", "CRITICAL"]:
            slack_message = {
                "text": f"Security Finding Alert:\nSeverity: {severity}\nResource: {resources}\nDescription: {description}"
            }

            http.request(
                "POST",
                os.environ["SLACK_WEBHOOK_URL"],
                body=json.dumps(slack_message),
                headers={"Content-Type": "application/json"},
            )