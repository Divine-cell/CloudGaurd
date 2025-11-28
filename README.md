# CloudGuard  Cloud Security Threat Detection and Alert Infrasturcture

**CloudGuard** is a cloud security architecture using Terraform to design, monitor cloud environments, detect threats, and send real-time alerts to a team via Slack. 

## Solution Overview
CloudGuard provides a fully automated workflow to detect and alert team on cloud security threats in when it happens.  

**Workflow:**
1. Fpr this project, EC2 instances simulate threats using Bash scripts.
2. **GuardDuty** detects threats and sends findings to **Security Hub**.
3. **EventBridge** imports findings and triggers a **Lambda** function.
4. Lambda checks **DynamoDB** for existing finding IDs.
   - If ID does not exist → send alert to Slack and save ID with TTL.
   - If ID exists → do not send alert (prevents duplicates).
5. **Batch optimization:** Lambda groups findings by **instance ID** to reduce alert noise.
6. Alerts are delivered to Slack in a concise, actionable format.


## Architecture Diagram
The architecture is designed to leverage AWS managed services for scalable and automated threat detection and notification. 


## AWS Services Used
CloudTrail: To provide an audit trail and source for threat detection           
GuardDuty:  To detects malicious activity in the cloud enviroment automatically  
<img width="1866" height="868" alt="Screenshot 2025-11-28 004430" src="https://github.com/user-attachments/assets/5bda6591-315b-4d98-bbab-9e7aef35e333" />

Security Hub: Aggregates findings from multiple services 
<img width="1897" height="873" alt="Screenshot 2025-11-28 004922" src="https://github.com/user-attachments/assets/1880e6e6-5b35-4237-aaa2-42b3656abefc" />

EventBridge: Triggers Lambda function automatically when new findings are imported  
Lambda:  Processes findings and sends alerts to Slack    
<img width="1901" height="875" alt="Screenshot 2025-11-28 004253" src="https://github.com/user-attachments/assets/1a15aff2-622b-463e-bf33-ffa3e8c356b3" />

DynamoDB: To Store finding IDs with TTL(Time To Live) and prevent duplicate alerts on slack
<img width="1107" height="786" alt="Screenshot 2025-11-26 221515" src="https://github.com/user-attachments/assets/c732c3db-84c5-4c36-9bb9-072dcc683722" />

EC2 + Bash: To simulates threats in the cloud environment providing scenarios to test monitorig security setup  
<img width="1892" height="457" alt="Screenshot 2025-11-28 004820" src="https://github.com/user-attachments/assets/0e75c158-21ea-45a9-98ea-6405d0b96d6d" />

Slack: To notify team of threat attacks on cloud environment 
<img width="1919" height="745" alt="Screenshot 2025-11-28 004154" src="https://github.com/user-attachments/assets/2bbd1182-837d-4ac2-94e3-761e7194a5bd" />

## Technologies Used
- **Infrastructure as Code:** Terraform
- **Scripting:** Bash
- **Serverless Functions:** AWS Lambda
- **Database:** DynamoDB
- **Monitoring & Security:** GuardDuty, CloudTrail, Security Hub
- **Messaging / Notification:** Slack
- **Cloud Provider:** AWS
