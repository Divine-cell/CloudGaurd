
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
              
              # Install netcat
              yum install -y nc curl
              
              # Log file
              LOG_FILE="/var/log/malicious-ip-test.log"
              
              echo "Starting malicious IP communication test..." > $LOG_FILE
              echo "Test started at: $(date)" >> $LOG_FILE
              
              # Known malicious IPs for testing (AWS GuardDuty test IPs)
              # These are safe test IPs maintained by AWS
              MALICIOUS_IPS=(
                "198.51.100.0/24"
                "203.0.113.0/24"

              )
              
              # Attempt connections to malicious IPs
              while true; do
                for ip in "$${MALICIOUS_IPS[@]}"; do
                  echo "[$(date)] Attempting connection to $ip" >> $LOG_FILE
                  
                  # Try multiple ports
                  for port in 80 443 8080; do
                    timeout 5 nc -zv $ip $port >> $LOG_FILE 2>&1 || true
                    sleep 5
                  done
                  
                  # Try HTTP request
                  timeout 5 curl -m 5 http://$ip >> $LOG_FILE 2>&1 || true
                  
                  sleep 10
                done
                
                sleep 60
              done
              EOF


  tags = {
    Name = "Malicious ip Threat simulation"
    Purpose = "Testing"
    Environment = "Dev"
  }
}

resource "aws_instance" "tor_netwwork_threats" {
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
              
              # Install EPEL repository (required for Tor)
              amazon-linux-extras install epel -y
              
              # Install Tor and dependencies
              yum install -y tor curl
              
              # Log file
              LOG_FILE="/var/log/tor-test.log"
              
              echo "Starting Tor network test..." > $LOG_FILE
              echo "Test started at: $(date)" >> $LOG_FILE
              
              # Configure Tor (basic config)
              cat > /etc/tor/torrc <<-TORRC
              SocksPort 9050
              ControlPort 9051
              Log notice file /var/log/tor/notices.log
              DataDirectory /var/lib/tor
              TORRC
              
              # Start Tor service
              systemctl start tor
              systemctl enable tor
              
              # Wait for Tor to initialize
              sleep 30
              
              echo "Tor started, checking status..." >> $LOG_FILE
              systemctl status tor >> $LOG_FILE 2>&1
              
              # Query Tor exit node list (this itself can trigger findings)
              while true; do
                echo "[$(date)] Querying Tor project..." >> $LOG_FILE
                curl -s https://check.torproject.org/exit-addresses >> $LOG_FILE 2>&1 || true
                
                sleep 120
                
                # Use Tor for outbound connections
                echo "[$(date)] Testing Tor SOCKS proxy..." >> $LOG_FILE
                curl --socks5 127.0.0.1:9050 http://check.torproject.org >> $LOG_FILE 2>&1 || true
                
                sleep 120
                
                # Check Tor IP
                echo "[$(date)] Checking IP via Tor..." >> $LOG_FILE
                curl --socks5 127.0.0.1:9050 http://icanhazip.com >> $LOG_FILE 2>&1 || true
                
                sleep 180
              done
              EOF

              
  tags = {
    Name = "tor network Threat simulation"
    Purpose = "Testing"
    Environment = "Dev"
  }
}



