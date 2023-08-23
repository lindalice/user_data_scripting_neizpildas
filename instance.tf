data "aws_ami" "d4ml_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["eks-ami-d4ml*"]
  }

  owners = ["823164954914"]
}

resource "aws_instance" "ll-scripting" {
  ami                  = data.aws_ami.d4ml_ami.id
  instance_type        = "t3.medium"
  subnet_id            = "subnet-0212031f1667e03a7"
  iam_instance_profile = "role-d4ml-cloud9-deployment"
  security_groups      = [aws_security_group.LL-Scripting-SG.id]
  user_data            = <<-EOT
            #!/bin/bash
            sudo -i 

            # Install required packages
            sudo apt-get update
            sudo apt-get install -y python3-pip
            pip3 install boto3


            # Change directory
            cd /opt/

            # IMDSv2 authorization token
            TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 300" "http://169.254.169.254/latest/api/token")

            # Add execute permissions to scripts
            sudo chmod +x variables2.sh
            sudo chmod +x variables.py

            # Run the scripts
            sh variables2.sh
            python3 variables.py

            # Upload output to S3 bucket
           aws s3 cp /opt/python_output.txt s3://d4ml-bucket/Linda_Lice/python_output.txt
           aws s3 cp /opt/shell_output.txt s3://d4ml-bucket/Linda_Lice/shell_output.txt
            EOT

  tags = {
    Name = "LL-Scripting"
  }
}

resource "aws_security_group" "LL-Scripting-SG" {
  name   = "LL-Scripting-SG"
  vpc_id = "vpc-0faf1b0abcce85736"

  egress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow custom port 9997"
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LL-Scripting-SG"
  }
}
