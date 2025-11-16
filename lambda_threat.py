import boto3
import random

# Lambda handler function
def lambda_handler(event, context):
    region = event.get("region", "us-east-1")
    
    threats = {
        "unauthorized_s3_access": UnauthorizedS3Access,
        "disable_cloudtrail": DisableCloudTrail,
        "iam_privilege_escalation": IamPrivilegeEscalation,
        "tamper_kms_key": TamperKMSKey,   
    }
    
    chosen_threat = random.sample(list(threats.values()), k=random.randint(1, 3))
    
    for threat in chosen_threat:
        try:
            threat(region)
        except Exception as e:
            print(f"Error simulating threat: {str(e)}")
        
    return {'statusCode': 200, 'body': 'Threat simulation completed successfully'}


# Threat simulation function for IAM Privilege Escalation
def IamPrivilegeEscalation(region):
    """Simulate IAM Privilege Escalation by creating a new user."""
    iam = boto3.client('iam', region_name=region)
    print("Simulating IAM Privilege Escalation...")
    
    try:
        iam.create_user(UserName='ForbiddenUser')    
    except Exception as e:
        print(f"Expected IAM failure: {str(e)}")
  
  
# Threat simulation function for Unauthorized S3 Access     
def UnauthorizedS3Access(region):
    """Simulate Unauthorized S3 Access by attempting to list a restricted bucket."""
    s3 = boto3.client('s3', region_name=region)
    print("Simulating Unauthorized S3 Access...")
    
    buckets = ["confidential_data12", "production_backups34", "financial_records56"]
    
    for bucket in buckets:
        try:
            s3.list_objects_v2(Bucket=bucket)
        except Exception as e:
            print(f"Expected S3 failure: {str(e)}")


# Threat simulation function for Disabling CloudTrail
def DisableCloudTrail(region):
    """Simulating an attempt to disable cloudtrail logging."""
    cloudtrail = boto3.client('cloudtrail', region_name=region)
    print("Simulating Disable CloudTrail...")
    
    try:
        cloudtrail.stop_logging(Name='Default')
        print("CloudTrail logging disabled.")
    except Exception as e:
        print(f"Expected CloudTrail failure: {str(e)}")
    
    # Attempt to disable multi-region logging as well
    try:
        cloudtrail.update_trail(Name='Default', isMultiRegionTrail=False)
        print("CloudTrail multi-region logging disabled.")
    except Exception as e:
        print(f"Expected CloudTrail multi-region failure: {str(e)}")


# Threat simulation function for Tampering with KMS Key
def TamperKMSKey(region):
    """Simulate tampering with a KMS key by attempting to disable it."""
    kms = boto3.client('kms', region_name=region)
    print("Simulating Tamper KMS Key...")
    
    key_Id = "alias/ThreatSimulationKey"
    
    try:
        kms.disable_key(KeyId=key_Id)
        print("KMS Key disabled.")
    except Exception as e:
        print(f"Expected KMS failure: {str(e)}")
    
    # Attempt to schedule key deletion
    try:
        kms.schedule_key_deletion(KeyId=key_Id, PendingWindowInDays=7)
        print("KMS Key deletion scheduled.")
    except Exception as e:
        print(f"Expected KMS deletion failure: {str(e)}")
        
    
    
