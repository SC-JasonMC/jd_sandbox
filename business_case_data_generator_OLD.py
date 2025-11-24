import argparse
import os
import pandas as pd
import boto3

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--profile_name", help="Use profile name from credentials file")

args = parser.parse_args()

def get_pricing_options(servers_csv_data):
    session = boto3.Session(profile_name=args.profile_name)
    pricing_source = session.client('pricing', region_name='us-east-1')
    for server in servers_csv_data.itertuples(index=False):
        instance_type = server.instance_type
        ebs_type = server.ebs_type
        ebs_size = server.ebs_size
        tenancy = server.tenancy
        pricing_options = pricing_source.get_products(
            ServiceCode='AmazonEC2',
            Filters=[
                {'Field': 'instanceType', 'Value': instance_type, 'Type': 'TERM_MATCH'},
                {'Field': 'volumeType', 'Value': ebs_type, 'Type': 'TERM_MATCH'},
                {'Field': 'location', 'Value': 'EU (London)', 'Type': 'TERM_MATCH'},
                {'Field': 'storage', 'Value': str(ebs_size), 'Type': 'TERM_MATCH'},
                {'Field': 'tenancy', 'Value': tenancy, 'Type': 'TERM_MATCH'},
                {'Field': 'preInstalledSw', 'Value': 'NA', 'Type': 'TERM_MATCH'},
                {'Field': 'productFamily', 'Value': 'Compute Instance', 'Type': 'TERM_MATCH'}
            ]

        )
    print("PRICING RESULTS:", pricing_options)
    return pricing_options

def read_servers_csv(servers_csv_full_path):
    with open(servers_csv_full_path) as csvfile:
        csv_data = pd.read_csv(csvfile)
        filtered_data = csv_data[['Server Name', 'Provisioning | Operating System', 'AWS | EC2 Instance', 'AWS | EC2 Tenancy', 'AWS | EBS Size (GB)', 'AWS | EBS Type', 'AWS | Annual Infrastructure Cost']]
        renamed = filtered_data.rename(columns={"Server Name" : "server_name", "Provisioning | Operating System" : "server_os", "AWS | EC2 Instance" : "instance_type", "AWS | EC2 Tenancy" : "tenancy", "AWS | EBS Size (GB)" : "ebs_size", "AWS | EBS Type" : "ebs_type", "AWS | Annual Infrastructure Cost" : "annual_cost"})
    return renamed

print("Enter the unzipped folder path containing the CSVs:")
csv_path = input()
# print("Which region are you planning to use?")
# aws_region = input()
csv_list = os.listdir(csv_path)
for csv_file in csv_list:
    if "servers" in csv_file:
        servers_csv = csv_file
        servers_csv_full_path = csv_path + "\\" + servers_csv
    if "sql" in csv_file:
        sql_csv = csv_file
        sql_csv_full_path = csv_path + "\\" + sql_csv
        
servers_csv_data = read_servers_csv(servers_csv_full_path)
# print(servers_csv_data)

pricing_options = get_pricing_options(servers_csv_data)
        

