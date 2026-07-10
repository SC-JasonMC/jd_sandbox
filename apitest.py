import os
import boto3
import pandas as pd
import numpy as np

def get_new_instance_type(ec2_client, x, t_inst_data_cache, max_attempts=5):
    min_ram = int(t_inst_data_cache[x]['data']['InstanceTypes'][0]['MemoryInfo']['SizeInMiB'])
    max_ram = int(t_inst_data_cache[x]['data']['InstanceTypes'][0]['MemoryInfo']['SizeInMiB'])
    attempts = 0
    while attempts < max_attempts:
        new_instance_type = ec2_client.get_instance_types_from_instance_requirements(
            ArchitectureTypes=[
                str(t_inst_data_cache[x]['data']['InstanceTypes'][0]['ProcessorInfo']['SupportedArchitectures'][0])
            ],
            VirtualizationTypes=[
                str(t_inst_data_cache[x]['data']['InstanceTypes'][0]['SupportedVirtualizationTypes'][0])
            ],
            InstanceRequirements={
                'AllowedInstanceTypes': ['c6a.*', 'm6a.*', 'r6a.*'],
                'VCpuCount': {
                    'Min': int(t_inst_data_cache[x]['data']['InstanceTypes'][0]['VCpuInfo']['DefaultVCpus']),
                    'Max': int(t_inst_data_cache[x]['data']['InstanceTypes'][0]['VCpuInfo']['DefaultVCpus'])
                },
                'MemoryMiB': {
                    'Min': min_ram,
                    'Max': max_ram
                }
            }
        )
        if new_instance_type['InstanceTypes']:
            return new_instance_type['InstanceTypes'][0]['InstanceType']
        max_ram *= 2
        attempts += 1
    return None

def get_current_instance_details(ec2_client, instance_type):
    instance_data = ec2_client.describe_instance_types(
        InstanceTypes=[
            instance_type
        ]
    )
    return instance_data

ec2_client = boto3.client('ec2', region_name='us-east-1')
input_dir = "C:\\Users\\McleodJ\\OneDrive - SOFTCAT PLC\\Documents\\pytest\\mgn"

xlsx_path = [
        os.path.join(dirpath,f) 
        for (dirpath, dirnames, filenames) 
        in os.walk(input_dir) 
        for f in filenames
        if f.endswith("xlsx")
    ][0]

df = pd.read_excel(xlsx_path, sheet_name="Shared Tenancy Data", skiprows=1, usecols=["Server Name", "EC2 Instance", "CPU Peak Usage %"])

filtered = df[
    df['EC2 Instance'].str.contains("Can't move Win Desktop") == False &
    df['EC2 Instance'].notna()
    ].copy()

t_instances = filtered[
    filtered['EC2 Instance'].str.startswith('t')
]

t_inst_data_cache = {}

for inst in t_instances['EC2 Instance'].unique():
        instance_data = get_current_instance_details(ec2_client, inst)
        if inst not in t_inst_data_cache:
            t_inst_data_cache[inst] = {}
        t_inst_data_cache[inst]["data"] = instance_data

filtered['new_type'] = filtered['EC2 Instance']
mask = filtered['EC2 Instance'].str.startswith('t')

filtered.loc[mask, 'new_type'] = filtered.loc[mask, 'EC2 Instance'].apply(lambda x: get_new_instance_type(ec2_client, x, t_inst_data_cache))

print(filtered)

