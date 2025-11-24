import boto3
import json
import requests

# Add more regions here as needed
location_mapping = {
    'eu-west-2': 'EU (London)',
    'eu-west-1': 'EU (Ireland)',
    'us-east-1': 'US East (N. Virginia)',
}

def get_on_demand_price(instance_type, region_name, os='Windows'):
    pricing = boto3.client('pricing', region_name='us-east-1')
    filters = [
        {'Type': 'TERM_MATCH', 'Field': 'instanceType', 'Value': instance_type},
        {'Type': 'TERM_MATCH', 'Field': 'location', 'Value': location_mapping[region_name]},
        {'Type': 'TERM_MATCH', 'Field': 'operatingSystem', 'Value': os},
        {'Type': 'TERM_MATCH', 'Field': 'tenancy', 'Value': 'Shared'},
        {'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': 'NA'},
        {'Type': 'TERM_MATCH', 'Field': 'capacitystatus', 'Value': 'Used'},
        {'Type': 'TERM_MATCH', 'Field': 'licenseModel', 'Value': 'No License required'}

    ]

    # Check if OS contains SQL info
    if 'SQL:' in os:
        # Extract edition after "SQL:"
        sql_edition = os.split('SQL:')[1].strip()
        filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': f'SQL Server {sql_edition}'})
    else:
        filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': 'NA'})

    # Add licenseModel for Windows
    if os.startswith('Windows'):
        filters.append({'Type': 'TERM_MATCH', 'Field': 'licenseModel', 'Value': 'No License required'})




    response = pricing.get_products(ServiceCode='AmazonEC2', Filters=filters, MaxResults=1)
    if not response['PriceList']:
        return None
    product = json.loads(response['PriceList'][0])
    for term in product['terms']['OnDemand'].values():
        for price in term['priceDimensions'].values():
            return float(price['pricePerUnit']['USD'])
        
def get_ec2_instance_savings_plan_rate(instance_type, region_code, os='Windows', term='3yr', payment='No Upfront'):
    # url = "https://pricing.us-east-1.amazonaws.com/savingsPlan/v1.0/aws/AWSComputeSavingsPlan/current/region_index.json"
    url = "https://pricing.us-east-1.amazonaws.com/savingsPlan/v1.0/aws/AWSComputeSavingsPlan/20251120054028/eu-west-2/index.json"
    response = requests.get(url)
    # print(response)
    if not response.ok:
        return None
    data = response.json()
    # print("Data: ", data)

    for sku, product in data['products'].items():
        attr = product.get('attributes', {})
        # Match EC2 Instance Savings Plans for the given instance type
        if (
            attr.get('instanceType') == instance_type and
            attr.get('regionCode') == region_code and
            attr.get('operatingSystem') == os and
            attr.get('tenancy') == 'shared' and
            attr.get('productFamily') == 'EC2InstanceSavingsPlans'
        ):
            terms = data['terms']['SavingsPlan'].get(sku, {})
            for offer in terms.values():
                term_attr = offer['termAttributes']
                if term_attr['termLength'] == term and term_attr['paymentOption'] == payment:
                    for dim in offer['priceDimensions'].values():
                        return float(dim['pricePerUnit']['USD'])  # This is the per-hour cost for the instance
    return None

# def get_reserved_price(instance_type, region_name, term='1yr', payment='No Upfront', os='Linux'):
#     pricing = boto3.client('pricing', region_name='us-east-1')
#     filters = [
#         {'Type': 'TERM_MATCH', 'Field': 'instanceType', 'Value': instance_type},
#         {'Type': 'TERM_MATCH', 'Field': 'location', 'Value': location_mapping[region_name]},
#         {'Type': 'TERM_MATCH', 'Field': 'operatingSystem', 'Value': os},
#         {'Type': 'TERM_MATCH', 'Field': 'tenancy', 'Value': 'Shared'},
#         {'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': 'NA'},
#         {'Type': 'TERM_MATCH', 'Field': 'capacitystatus', 'Value': 'Used'},
#     ]
#     response = pricing.get_products(ServiceCode='AmazonEC2', Filters=filters, MaxResults=1)
#     if not response['PriceList']:
#         return None
#     product = json.loads(response['PriceList'][0])
#     for term in product['terms']['Reserved'].values():
#         attr = term['termAttributes']
#         if attr['LeaseContractLength'] == term and attr['PurchaseOption'] == payment:
#             for price in term['priceDimensions'].values():
#                 return float(price['pricePerUnit']['USD'])


# def get_savings_plan_rate(instance_type, region_code, os='Linux'):
#     url = "https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AWSSavingsPlans/current/AWSSavingsPlans.json"
#     response = requests.get(url)
#     if not response.ok:
#         return None
#     data = response.json()
#     for sku, product in data['products'].items():
#         attr = product.get('attributes', {})
#         if (
#             attr.get('instanceType') == instance_type and
#             attr.get('regionCode') == region_code and
#             attr.get('operatingSystem') == os and
#             attr.get('tenancy') == 'shared'
#         ):
#             terms = data['terms']['SavingsPlan'].get(sku, {})
#             for offer in terms.values():
#                 for dim in offer['priceDimensions'].values():
#                     return float(dim['pricePerUnit']['USD'])
#     return None

# === Example usage ===
instance_type = 'm6a.large'
region = 'eu-west-2'

print("Gathering pricing for:", instance_type, "in", region)

on_demand = get_on_demand_price(instance_type, region)
# reserved = get_reserved_price(instance_type, region)
# savings = get_ec2_instance_savings_plan_rate(instance_type, region)

print(f"On-Demand: ${on_demand:.4f}/hr")
# print(f"Reserved (1yr, No Upfront): ${reserved:.4f}/hr" if reserved else "Reserved pricing not available")
# print(f"Savings Plan: ${savings:.4f}/hr" if savings else "Savings Plan rate not available")
