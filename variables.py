#!/usr/bin/env python3

import requests
import boto3

def get_metadata_token():
    """Get a session token for accessing instance metadata."""
    try:
        response = requests.put('http://169.254.169.254/latest/api/token', headers={'X-aws-ec2-metadata-token-ttl-seconds': '21600'})
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        print(f"Error fetching metadata token: {e}")
        exit(1)

def fetch_metadata(endpoint, token):
    """Fetch instance metadata using session token."""
    try:
        response = requests.get(f'http://169.254.169.254/latest/meta-data/{endpoint}', headers={'X-aws-ec2-metadata-token': token})
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        print(f"Error fetching metadata for {endpoint}: {e}")
        exit(1)

# Get metadata session token
token = get_metadata_token()

# Fetch region and then set up EC2 and STS clients for that region
region_name = fetch_metadata('placement/region', token)
ec2 = boto3.resource('ec2', region_name=region_name)
sts = boto3.client('sts', region_name=region_name)

# Get instance ID from metadata
instance_id = fetch_metadata('instance-id', token)

# Get the tags for the current instance, and check if tags exist
tags = ec2.Instance(instance_id).tags or []

# Extract the 'Name' tag value
instance_name = next((tag['Value'] for tag in tags if tag['Key'] == 'Name'), None)

# Define and retrieve the variables dictionary
variables = {
    'region_name': region_name,
    'az_name': fetch_metadata('placement/availability-zone', token),
    'private_ip': fetch_metadata('local-ipv4', token),
    'public_ip': fetch_metadata('public-ipv4', token),
    'instance_id': instance_id,
    'account_number': sts.get_caller_identity()['Account'],
    'instance_name': instance_name
}

# Write variables to a file
with open('/opt/python_output.txt', 'w') as file:
    for key, value in variables.items():
        file.write(f"{key}: {value}\n")