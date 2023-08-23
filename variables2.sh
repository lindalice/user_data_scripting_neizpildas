#!/bin/bash

# Generate a token for IMDSv2
metadata_token="$(curl -X PUT 'http://169.254.169.254/latest/api/token' -H 'X-aws-ec2-metadata-token-ttl-seconds: 3600')"

# Function to retrieve metadata with token
get_metadata() {
    endpoint=$1
    curl -s -H "X-aws-ec2-metadata-token: $metadata_token" "http://169.254.169.254/latest/meta-data/$endpoint"
}

# Define the global variables to retrieve
Region_Name=$(get_metadata "placement/region")
Availability_Zone_Name=$(get_metadata "placement/availability-zone")
Public_IP_Address=$(get_metadata "public-ipv4")
Private_IP_Address=$(get_metadata "local-ipv4")
Instance_ID=$(get_metadata "instance-id")
AMI_ID=$(get_metadata "ami-id")
Instance_Type=$(get_metadata "instance-type")
AccountID=$(curl -s -H "X-aws-ec2-metadata-token: $metadata_token" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.accountId')

# Debug
echo "DEBUG: Region Name is $Region_Name"

if [ -z "$Region_Name" ]; then
    echo "Error: Region name is empty"
    exit 1
fi

InstanceName=$(aws ec2 describe-instances --instance-id $Instance_ID --region $Region_Name --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value[]' --output text)

# Write the output to file
echo "Instance Name: $InstanceName" >> /opt/shell_output.txt
echo "Account ID Number: $AccountID" >> /opt/shell_output.txt
echo "Region Name: $Region_Name" >> /opt/shell_output.txt
echo "Availability Zone Name: $Availability_Zone_Name" >> /opt/shell_output.txt
echo "Public IPv4: $Public_IP_Address" >> /opt/shell_output.txt
echo "Private IPv4: $Private_IP_Address" >> /opt/shell_output.txt
echo "Instance ID: $Instance_ID" >> /opt/shell_output.txt
echo "AMI ID: $AMI_ID" >> /opt/shell_output.txt
echo "Instance Type: $Instance_Type" >> /opt/shell_output.txt