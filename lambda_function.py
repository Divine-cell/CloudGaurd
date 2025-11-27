import json
import os
import urllib3
import time
import boto3


SLACK_WEBHOOK = os.environ['SLACK_WEBHOOK_URL']
DDB_TABLE = os.environ['DDB_TABLE']
DDB_TTL_MINUTES = int(os.environ.get("DDB_TTL_MINUTES", 120))


http = urllib3.PoolManager()
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(DDB_TABLE)

def lambda_handler(event, context):
    findings = event.get("detail", {}).get("findings", [])
    
    # Group findings by instance ID
    grouped = {}
    
    for record in findings:
        instance_id = "UNKNOWN"
        if "Resources" in record and len(record["Resources"]) > 0:
            instance_id = record["Resources"][0].get("Id", "UNKNOWN")

        if instance_id not in grouped:
            grouped[instance_id] = []
        grouped[instance_id].append(record)
    
    for instance_id, finding_list in grouped.items():
        dedup_key = f"{instance_id}"
        
        existing_id = table.get_item(Key={"FindingID": dedup_key})
        if "Item" in existing_id:
            print(f"Skipping {instance_id}")
            continue
        
        ttl_value = int(time.time() + (DDB_TTL_MINUTES * 60))
        table.put_item(Item={
            "FindingID": dedup_key,
            "ttl": ttl_value
        })
        
        severities = []
        descriptions = []
        
        for record in finding_list:
            sev_obj = record.get("Severity", {})
            severity = sev_obj.get("Label") or sev_obj.get("label") or "UNKNOWN"
            description = record.get("Description", "No description provided")

            severities.append(severity)
            descriptions.append(description)
        
         # Highest severity for the instance    
        highest_sev = max(severities, key=lambda s: ["LOW","MEDIUM","HIGH","CRITICAL"].index(s) 
                          if s in ["LOW","MEDIUM","HIGH","CRITICAL"] else 0)
  

        slack_message = {
            "text": (
                f"*Security Findings Summary*\n"
                f"*Instance:* `{instance_id}`\n"
                f"*Total Findings:* {len(finding_list)}\n"
                f"*Highest Severity:* {highest_sev}\n\n"
                f"*Descriptions:*\n" +
                "\n".join([f"- {d}" for d in descriptions])
            )
        }

        http.request(
            "POST",
            os.environ["SLACK_WEBHOOK_URL"],
            body=json.dumps(slack_message),
            headers={"Content-Type": "application/json"},
        )