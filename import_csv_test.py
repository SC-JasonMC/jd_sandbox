# import csv
import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--filepath")

args = parser.parse_args()

# filepath = "C:\\Users\\McleodJ\\OneDrive - SOFTCAT PLC\\Documents\\Clients\\IWG\\account_list.csv"

df = pd.read_csv(args.filepath, sep='\t')

for index, row in df.iterrows():
    print(f"Profile: {row['Profile']}")

# print(df)

# profiles = df['Profile']

# print(profiles)

# with open(filepath, mode='r') as file:
#     csv_reader = csv.DictReader(file)  # Create DictReader

#     data_list = []  # List to store dictionaries
#     for row in csv_reader:
#         data_list.append(row)

# for data in data_list:
#     print(data)


