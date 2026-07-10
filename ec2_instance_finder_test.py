# NOTE TO SELF:
# You're trying to get instance data from the API to extract CPU and RAM per insance type.
# Once you have that, you want to include a function in the main script
# to look for t instances, match CPU and RAM as closely as possible, and then replace with something that's not a t instance.
# If you can do this, you no longer need to maintain a manual "map" of instance types in the script.
# On Friday, you were working on drilling down into the dict to extract the info you need.

# ALSO: Look at the xlsx where servers don't have an instance type and figure out why. Are these zombies?

import os
import boto3
import pandas as pd
import numpy as np

# Establish current directory for downloads and saved files (Git ignores this)
current_dir = os.getcwd()
input_dir = "C:\\Users\\McleodJ\\OneDrive - SOFTCAT PLC\\Documents\\pytest\\mgn"

def get_new_instance_type(instance_data, min_cpu, mac_cpu, min_ram, max_ram, max_attempts=5):
    attempts = 0
    while attempts < max_attempts:
        new_instance_type = ec2_client.get_instance_types_from_instance_requirements(
            ArchitectureTypes=[
                str(instance_data['InstanceTypes'][0]['ProcessorInfo']['SupportedArchitectures'][0])
            ],
            VirtualizationTypes=[
                str(instance_data['InstanceTypes'][0]['SupportedVirtualizationTypes'][0])
            ],
            InstanceRequirements={
                'AllowedInstanceTypes': ['m6a.*', 'c6a.*', 'r6a.*'],
                'VCpuCount': {
                    'Min': min_cpu,
                    'Max': max_cpu
                },
                'MemoryMiB': {
                    'Min': min_ram,
                    'Max': max_ram
                }
            }
        )
        if new_instance_type['InstanceTypes']:
            return new_instance_type
        max_ram *= 2
        attempts += 1
    return None

xlsx_path = [
        os.path.join(dirpath,f) 
        for (dirpath, dirnames, filenames) 
        in os.walk(input_dir) 
        for f in filenames
        if f.endswith("xlsx")
    ][0]

df = pd.read_excel(xlsx_path, sheet_name="Shared Tenancy Data", skiprows=1, usecols=["Server Name", "EC2 Instance"])
# print(df)

filtered = df[
    df['EC2 Instance'].str.contains("Can't move Win Desktop") == False &
    df['EC2 Instance'].notna()
    ]

for inst in filtered['EC2 Instance'].unique():
        new_type = get_new_instance_type(inst, min_cpu, mac_cpu, min_ram, max_ram)
        if inst not in od_price_cache:
            od_price_cache[inst] = {}
        od_price_cache[inst]["Windows"] = price

filtered['new_type'] = np.where(
    filtered['EC2 Instance'].str.startswith('t'),
    "REPLACE",
    filtered['EC2 Instance']
)

print(filtered)









# adjusted_compute['instance'] = np.where(
#     base_df['cpu_util'] >= predicted_cpu_threshold,
#     base_df["instance"].map(instance_type_map).fillna(adjusted_compute["instance"]),
#     base_df["instance"]
# )

# # filtered['new_type'] = 

# filtered["new_type"] = filtered.apply(replace_instance_type, axis=1, args=(sp_rates_data, "ComputeSP:1yrNoUpfront",))

# print(filtered)

# for row in df['EC2 Instance']:
#     if row == "Can't move Win Desktop":
#         continue
#     if pd.isna(row):
#         continue
#     # print(row)
#     if row.startswith('t'):
#         print(row)

# # # test = "t3a.medium"

#         instance_data = ec2_client.describe_instance_types(
#             InstanceTypes=[
#                 row
#             ]
#         )

#         instance_cpu = instance_data['InstanceTypes'][0]['VCpuInfo']['DefaultVCpus']
#         instance_ram = instance_data['InstanceTypes'][0]['MemoryInfo']['SizeInMiB']

#         print(instance_cpu)
#         print(instance_ram)
