import boto3
import json
import os
import wget
import argparse
import pandas as pd
import numpy as np
from urllib.request import urlopen

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--input_file", help="Enter input file path")

args = parser.parse_args()

# Establish current directory for downloads and saved files (Git ignores this)
current_dir = os.getcwd()

# Info for building the price index URL
base_url = "https://pricing.us-east-1.amazonaws.com"
hop_1 = "/offers/v1.0/aws/index.json"
# Set service you want to get prices for
target_service = "AmazonEC2"

# Set local file paths and names
local_index_file = (f"{current_dir}\\pricing_index.json")
output_file_path = args.input_file.rsplit("\\", 1)[0]
output_file = (f"{output_file_path}\\processed_data.xlsx")

# Set savings plan parameters (this is what the script will try and find prices for)
sp_type = "ComputeSP:3yrNoUpfront"
region = "eu-west-2"
region_code = "EUW2"
usage_type = "BoxUsage"

# Set CSV parameters
predicted_cpu_threshold = 30.00 # Any CPU utilisation value >= this threshold that is also a 't' instance type will be remapped according to the instance_type_map
compute_headers = ["Server Name", "OS", "Recommended Instance", "Predicted CPU Utilization (%)"] # The headers needed to start off. The script adds the rest and builds a new CSV.

# Location mapping since the pricing API needs the "proper" name, for reasons best known to itself.
location_mapping = {
    'eu-west-2': 'EU (London)',
    'eu-west-1': 'EU (Ireland)',
    'us-east-1': 'US East (N. Virginia)',
}

# If a T instance has utilisation >= the threshold set above, this is the instance type it will be changed to.
instance_type_map = {
    't3a.medium': 'c6a.large',
    't3a.large': 'm6a.large',
    't3a.small': 'c6a.large',
    't3a.xlarge': 'm6a.xlarge'
}

# Discount codes set by AWS. The script uses this as one of the search terms to get the correct pricing per instance type. Some are repeated because OLA outputs can use different wording.
discounted_op_map = {
    # Windows common options
    'Windows' : 'RunInstances:0002',
    'Windows with SQL Server Standard' : 'RunInstances:0006',
    'Windows (MS SQL Standard)' : 'RunInstances:0006',
    'SQLSTD' : 'RunInstances:0006',
    'Windows with SQL Server Enterprise' : 'RunInstances:0102',
    'Windows (MS SQL Enterprise)' : 'RunInstances:0102',
    'SQLENT' : 'RunInstances:0102',
    'Windows (MS SQL Web)' : 'RunInstances:0102',
    'Windows with SQL Server Web' : 'RunInstances:0202',
    'SQLWEB' : 'RunInstances:0202',
    # These are Linux with SQL Server
    'SQL Server Standard' : 'RunInstances:0004',
    'SQL Server Enterprise' : 'RunInstances:0100',
    'SQL Server Web' : 'RunInstances:0200',
    'Windows BYOL' : 'RunInstances:0800',
    # These are untested so far
    'Red Hat BYOL Linux' : 'RunInstances:00g0',
    'Red Hat Enterprise Linux' : 'RunInstances:0010',
    'Red Hat Enterprise Linux with HA' : 'RunInstances:1010',
    'Red Hat Enterprise Linux with SQL Server Standard and HA' : 'RunInstances:1014',
    'Red Hat Enterprise Linux with SQL Server Enterprise and HA' : 'RunInstances:1110',
    'Red Hat Enterprise Linux with SQL Server Standard' : 'RunInstances:0014',
    'Red Hat Enterprise Linux with SQL Server Web' : 'RunInstances:0210',
    'Red Hat Enterprise Linux with SQL Server Enterprise' : 'RunInstances:0110',
    'SUSE Linux' : 'RunInstances:000g',
    'Ubuntu Pro' : 'RunInstances:0g00',
    # If no match, it defaults to Linux
    'Linux/UNIX' : 'RunInstances'
}

# Download the index file from the base URL and gets the version URL for the relevant service
def find_price_index_data_url(base_url, hop_1):
    print("Searching for latest Price Index...\n")
    hop_1_url = (f"{base_url}{hop_1}")
    with urlopen(hop_1_url) as hop_1_response:
        hop_2 = json.load(hop_1_response)['offers'][target_service]['currentSavingsPlanIndexUrl']
        hop_2_url = (f"{base_url}{hop_2}")

    # Use the URL built from the first section above to get the region index
    with urlopen(hop_2_url) as hop_2_response:
        hop_3_data = json.load(hop_2_response)['regions']
        # Download the region index and get the price index URL (this is the one you want)
        for region_info in hop_3_data:
            if region_info['regionCode'] == region:
                hop_3 = region_info['versionUrl']
                hop_3_url = (f"{base_url}{hop_3}")
                return hop_3_url

# Download the Price Index json file and store it locally (git will ignore it)            
def download_price_index(price_index_data_url, local_index_file):
    
    url = price_index_data_url
    # If you already have a copy, it will be replaced.
    if os.path.exists(local_index_file):
        print(f"Updating local price index.\n")
        os.remove(local_index_file)
    else:
        print("Downloading latest Price index...\n")
    filepath = wget.download(url, out = local_index_file)
    return filepath

# use the input and external data to build your output CSV
def process_compute_data(output_file_path, compute_headers, input_file):

    # Read only the selected columns from the CSV
    df = pd.read_excel(input_file, sheet_name="Compute", skiprows=1, usecols=compute_headers)

    # Add new columns to build on data
    print(f"Cleaning up the data and adding terminology...\n")

    # Clean up SQL data so it's usable
    df['sql_ed'] = df['OS'].apply(get_sql_edition)

    # clean up OS data so it's usable
    df['base_os'] = df['OS'].apply(get_base_os)

    # Change instance type if criteria is met, else copy existing to new column
    df['target_type'] = np.where(
        df['Predicted CPU Utilization (%)'] >= predicted_cpu_threshold,
        df["Recommended Instance"].map(instance_type_map).fillna(df["Recommended Instance"]),
        df["Recommended Instance"]
    )

    # Set discount code from map
    df['usage_op'] = np.where(
        df['OS'].str.contains('Windows'),
        df['OS'].map(discounted_op_map).fillna('RunInstances'),
        'RunInstances'
    )

    print("Gathering latest prices for your projected instances...\n")

    # Get on-demand pricing from Pricing API
    df["od_rate"] = df.apply(get_on_demand_price, axis=1)
    df["od_rate"] = pd.to_numeric(df["od_rate"], errors="coerce")
    df["od_annual"] = df["od_rate"] * 365 * 24

    # Get savings plan pricing from local Pricing Index file
    df["sp_rate"] = df.apply(get_savings_plan_rate, axis=1, args=(sp_rates_data, sp_type,))
    df["sp_rate"] = pd.to_numeric(df["sp_rate"], errors="coerce")
    df["sp_annual"] = df["sp_rate"] * 365 * 24

    # Format and apply data
    results = df.to_dict(orient='records')

    # Export CSV to current directory (git will ignore it)
    if os.path.exists(output_file):
        print(f"Deleting previous output file..\n")
        os.remove(output_file)
    df.to_excel(output_file, index=False)

    return results

# Helper function to fill in base OS column for consistent data. Set to Windows or Linux only based on the contents of the OS field.
def get_base_os(os_field):
    if 'Windows' in os_field:
        return 'Windows'
    return 'Linux'

# Helper function to fill in SQL edition column for consistent data. Set to shortcode for SQL or leave empty if not a SQL Server.
def get_sql_edition(os_field):
    if 'SQL' in os_field:
        if 'Standard' in os_field:
            return 'SQLSTD'
        elif 'Enterprise' in os_field:
            return 'SQLENT'
        elif 'Web' in os_field:
            return 'SQLWEB'
    return ''

# Helper function to extract the correct savings plan rate for each row when processing the CSV
def get_savings_plan_rate(row, sp_rates_data, sp_type):
    discounted_usage_type = f"{region_code}-{usage_type}:{row['target_type']}"
    with open(sp_rates_data, 'r') as file:
        data = json.load(file)
        for product in data['products']:
            if product['attributes'].get('usageType') == sp_type:
                # return product['sku']
                for plan in data['terms']['savingsPlan']:
                    if plan.get('sku') == product['sku']:
                        for rate in plan.get('rates', []):
                            if rate.get('discountedUsageType') == discounted_usage_type and rate.get('discountedOperation') == row['usage_op']:
                                return rate['discountedRate']['price']

# Helper function to extract the correct on-demand rate for each row when processing the CSV                            
def get_on_demand_price(row):
    pricing = boto3.client('pricing', region_name='us-east-1')
    filters = [
        {'Type': 'TERM_MATCH', 'Field': 'instanceType', 'Value': row['target_type']},
        {'Type': 'TERM_MATCH', 'Field': 'location', 'Value': location_mapping[region]},
        {'Type': 'TERM_MATCH', 'Field': 'operatingSystem', 'Value': row['base_os']},
        {'Type': 'TERM_MATCH', 'Field': 'tenancy', 'Value': 'Shared'},
        {'Type': 'TERM_MATCH', 'Field': 'capacitystatus', 'Value': 'Used'}
    ]

    # Check if OS contains SQL info
    if row['sql_ed']:
        if row['sql_ed'] == "SQLENT":
            filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': f'SQL Ent'})
        elif row['sql_ed'] == "SQLWEB":
            filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': f'SQL Web'})
        else:
            filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': f'SQL Std'})
    else:
        filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': 'NA'})

    # Add license model for Windows (default to LI for now)
    if row['base_os'] == "Windows":
        filters.append({'Type': 'TERM_MATCH', 'Field': 'licenseModel', 'Value': 'No License required'})

    response = pricing.get_products(ServiceCode='AmazonEC2', Filters=filters, MaxResults=1)
    if not response['PriceList']:
        return None
    product = json.loads(response['PriceList'][0])
    for term in product['terms']['OnDemand'].values():
        for price in term['priceDimensions'].values():
            return float(price['pricePerUnit']['USD'])
        
               
price_index_data_url = find_price_index_data_url(base_url, hop_1)
print("Price index found!\n")

sp_rates_data = download_price_index(price_index_data_url, local_index_file)
print("Price index downloaded!\n")

compute_data = process_compute_data(output_file_path, compute_headers, input_file=args.input_file)
print(f"Output is built! Find it at {output_file}")