# # Helper function to extract the correct on-demand rate for each row when processing the CSV                            
# def get_on_demand_price(row):
#     pricing = boto3.client('pricing', region_name='us-east-1')
#     filters = [
#         {'Type': 'TERM_MATCH', 'Field': 'instanceType', 'Value': row['Recommended Instance']},
#         {'Type': 'TERM_MATCH', 'Field': 'location', 'Value': location_mapping[region]},
#         {'Type': 'TERM_MATCH', 'Field': 'operatingSystem', 'Value': row['base_os']},
#         {'Type': 'TERM_MATCH', 'Field': 'tenancy', 'Value': 'Shared'},
#         {'Type': 'TERM_MATCH', 'Field': 'capacitystatus', 'Value': 'Used'}
#     ]

#     # Check if OS contains SQL info
#     if row['sql_edition']:
#         if row['sql_edition'] == "SQLENT":
#             filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': f'SQL Ent'})
#         elif row['sql_edition'] == "SQLWEB":
#             filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': f'SQL Web'})
#         else:
#             filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': f'SQL Std'})
#     else:
#         filters.append({'Type': 'TERM_MATCH', 'Field': 'preInstalledSw', 'Value': 'NA'})

#     # Add license model for Windows (default to LI for now)
#     if row['base_os'] == "Windows":
#         filters.append({'Type': 'TERM_MATCH', 'Field': 'licenseModel', 'Value': 'No License required'})

#     response = pricing.get_products(ServiceCode='AmazonEC2', Filters=filters, MaxResults=1)
#     if not response['PriceList']:
#         return None
#     product = json.loads(response['PriceList'][0])
#     for term in product['terms']['OnDemand'].values():
#         for price in term['priceDimensions'].values():
#             return float(price['pricePerUnit']['USD'])