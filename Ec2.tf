
resource "aws_key_pair" "generated" {
  key_name   = "test-key"
  public_key = var.public_key

}

resource "aws_instance" "crypto_Miniing_threat_Server" {
  ami = "ami-0fa3fe0fa7920f68e"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.threat_vpc_SG.id]
  subnet_id = aws_subnet.threat_public_subnet.id
  associate_public_ip_address = true
  key_name = aws_key_pair.generated.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install bind-utils for nslookup
              yum install -y bind-utils
              
              # Log file
              LOG_FILE="/var/log/crypto-mining-test.log"
              
              echo "Starting cryptocurrency mining DNS queries..." > $LOG_FILE
              echo "Test started at: $(date)" >> $LOG_FILE
              
              # Known cryptocurrency mining pool domains
              MINING_POOLS=(
                "pool.minergate.com"
                "xmr-eu1.nanopool.org"
                "xmr-us-east1.nanopool.org"
                "eth-eu1.nanopool.org"
                "eth-us-east1.nanopool.org"
                "eu.stratum.slushpool.com"
                "stratum.antpool.com"
                "pool.supportxmr.com"
                "xmr.crypto-pool.fr"
                "monerohash.com"
              )
              
              # Continuous DNS queries to mining pools
              while true; do
                for pool in "$${MINING_POOLS[@]}"; do
                  echo "[$(date)] Querying: $pool" >> $LOG_FILE
                  nslookup $pool >> $LOG_FILE 2>&1
                  sleep 10
                done
                sleep 30
              done
              EOF

  tags = {
    Name = "Crypto Threat simulation"
    Purpose = "Testing"
    Environment = "Dev"
  }
}

resource "aws_instance" "malicious_ip" {
  ami = "ami-0fa3fe0fa7920f68e"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.threat_vpc_SG.id]
  subnet_id = aws_subnet.threat_public_subnet.id
  associate_public_ip_address = true
  key_name = aws_key_pair.generated.key_name


  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y

              # Install tools
              yum install -y bind-utils curl wget nc

              # Log file
              LOG_FILE="/var/log/malicious-activity-test.log"

              echo "Starting malicious activity test..." > $LOG_FILE
              echo "Test started at: $(date)" >> $LOG_FILE

              MALICIOUS_DOMAINS=(
                "guarddutyc2activityb.com"
                "guarddutyabnormaldomain.com"
                "guardduty-multi-cloud-c2.com"
              )

              # Query known malicious domains
              while true; do
                for domain in "$${MALICIOUS_DOMAINS[@]}"; do
                  echo "[$(date)] Querying GuardDuty test domain: $domain" >> $LOG_FILE
                  nslookup $domain >> $LOG_FILE 2>&1 || true
                  sleep 20
                done

              # Simulate backdoor activity by scanning unusual local ports
              echo "[$(date)] Simulating backdoor activity..." >> $LOG_FILE
              timeout 2 nc -zv 127.0.0.1 31337 >> $LOG_FILE 2>&1 || true
              timeout 2 nc -zv 127.0.0.1 12345 >> $LOG_FILE 2>&1 || true

              sleep 60
              done
              EOF


  tags = {
    Name = "Malicious ip Threat simulation"
    Purpose = "Testing"
    Environment = "Dev"
  }
}