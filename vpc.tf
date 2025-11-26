resource "aws_vpc" "threat_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Threat VPC"
    Dev  = "Environment"
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "vpc_threat_log_group"
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name               = "allow_logs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
    
  })
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "flow_log_policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "arn:aws:logs:*:*:*"
      } 
    ]
    
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.threat_vpc.id
}


resource "aws_subnet" "threat_public_subnet" {
  vpc_id = aws_vpc.threat_vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true 
  cidr_block = "10.0.1.0/24"

}

resource "aws_security_group" "threat_vpc_SG" {
  vpc_id = aws_vpc.threat_vpc.id
  name = "EC2_access_sg"

  ingress {
    to_port = 22
    from_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule to ec2 threat"
  }

  ingress {
    to_port = 80
    from_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule to ec2 threat"
  }



  egress {
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "egress rule to ec2 threat"
  }
}

resource "aws_route_table" "Pubic_RT" {
  vpc_id = aws_vpc.threat_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
   
}

resource "aws_route_table_association" "RT_public_association" {
  subnet_id = aws_subnet.threat_public_subnet.id
  route_table_id = aws_route_table.Pubic_RT.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.threat_vpc.id

  tags = {
    Name = "Vpc threat IG"
  }
}
