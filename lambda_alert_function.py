import json
import os
import urlib3

SLACK_WEBHOOK = os.environ['SLACK_WEBHOOK_URL']
http = urlib3.PoolManager()
def lambda_handler(event, context):
    for record in event.get("detail", {}).get("findings", []):
        severity = record["Serverity"]["label"]
        resources = record["resources"][0][id]
        description = record["description"]

        if severity in ["HIGH", "CRITICAL"]:
            continue

        slack_message = {
            "text": f"Security Finding Alert:\nSeverity: {severity}\nResource: {resources}\nDescription: {description}"
        }

        response = http.request(
            "POST",
            os.environ["SLACK_WEBHOOK_URL"],
            body=json.dumps(slack_message),
            headers={"Content-Type": "application/json"},
        )