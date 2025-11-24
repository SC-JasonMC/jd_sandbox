from urllib.request import urlopen
import json

base_url = "https://pricing.us-east-1.amazonaws.com"
hop_1 = "/offers/v1.0/aws/index.json"
target_service = "AmazonEC2"
region = "eu-west-2"

# Specify the URL of the file
hop_1_url = (f"{base_url}{hop_1}")

def find_price_index_data_url(region):
    hop_1_url = (f"{base_url}{hop_1}")
    with urlopen(hop_1_url) as hop_1_response:
        # data = json.load(response)
        hop_2 = json.load(hop_1_response)['offers'][target_service]['currentSavingsPlanIndexUrl']
        hop_2_url = (f"{base_url}{hop_2}")
        # print(hop_2_url)
        # print(data['offers'][target_service][target_second_hop_key])
        # for k, v in data['offers'][target_service].items():
        #     print(f"{k} : {v}")

    with urlopen(hop_2_url) as hop_2_response:
        # print(region)
        hop_3_data = json.load(hop_2_response)['regions']
        for region_info in hop_3_data:
            if region_info['regionCode'] == region:
            # if region.get('regionCode') == region:
                hop_3 = region_info['versionUrl']
                hop_3_url = (f"{base_url}{hop_3}")
                return hop_3_url

price_index_data_url = find_price_index_data_url(region)
print(f"Price index URL: {price_index_data_url}")

