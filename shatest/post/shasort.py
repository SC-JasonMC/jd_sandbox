import boto3
import json
import os
import argparse
import datetime
import pandas as pd
import csv

today = datetime
current_date = datetime.date.today().strftime("%d %B %Y")

current_dir = os.getcwd()

def parse_args():
    parser = argparse.ArgumentParser(description="Prompt if argument not provided")
    parser.add_argument("-f", "--input_file", help="Enter input file path ")

    return parser.parse_args()

def main():
    args = parse_args()
    # If file path was not provided, prompt the user
    if not args.input_file:
        try:
            args.input_file = input("Enter input file path: ").strip()
            if not args.input_file:
                raise ValueError("File path cannot be empty.")
        except (EOFError, KeyboardInterrupt):
            print("\nInput cancelled.")
            exit(1)
        except ValueError as e:
            print(f"Error: {e}")
            exit(1)

    csv_columns = [
        'ACCOUNT_UID',
        'STATUS', 
        'CHECK_ID',
        'STATUS_EXTENDED', 
        'SERVICE_NAME', 
        'SEVERITY', 
        'RESOURCE_TYPE', 
        'RESOURCE_UID', 
        'RESOURCE_NAME',
        'REGION', 
        'DESCRIPTION', 
        'REMEDIATION_RECOMMENDATION_TEXT', 
        'REMEDIATION_RECOMMENDATION_URL'
        ]

    df = pd.read_csv(args.input_file, sep=';', usecols=csv_columns)

    # grouped_df = df.groupby('CHECK_ID').apply(lambda g: g[['RESOURCE_NAME', 'RESOURCE_UID']].to_dict('records')).to_dict()

    nested = {
        grouped: (
            grp.groupby('CHECK_ID')
            .apply(lambda g: {
                'resources': g[['RESOURCE_NAME', 'RESOURCE_UID']].to_dict('records'),
                'Finding': g['STATUS_EXTENDED'].iloc[0],
                'Recommendation': g['REMEDIATION_RECOMMENDATION_TEXT'].iloc[0],  # or unique()[0]
                'URL': g['REMEDIATION_RECOMMENDATION_URL'].iloc[0],
            }, include_groups=False)
            .to_dict()
        )

        for grouped, grp in df.groupby('SEVERITY')
    }

    
    severity_counts = df.groupby(['SEVERITY']).size().reset_index(name='count')

    service_counts = df.groupby(['SERVICE_NAME']).size().reset_index(name='count')

    with open('data.json', 'w', encoding='utf-8') as f:
        json.dump(nested, f, ensure_ascii=False, indent=4)


    # print(json.dumps(nested, indent=4))
    print(f"\nSeverity: \n{severity_counts}")
    print(f"\nService: \n{service_counts}")







    # findings_cache = {}

    # # Windows SQL BYOL pricing
    # for item in df['CHECK_ID'].unique():
    #     subset = df[df['CHECK_ID'] == item]
    #     # resource = df['RESOURCE_NAME']
    #     if item not in findings_cache:
    #         findings_cache[item] = {}
    #     # findings_cache[item]["arn"] = df['RESOURCE_UID']
        
    #     # findings_cache[item]["arn"] = subset['RESOURCE_UID'].tolist()
    #     findings_cache[item]["resource_names"] = subset['RESOURCE_UID'].tolist()


    # print(grouped)

    # delimiter = ";"

#     df = txt_to_dataframe(delimiter, input_file=args.input_file)  # or None for auto-detect
#     print("DataFrame loaded successfully:")
#     print(df.keys())  # Show first 5 rows

# def txt_to_dataframe(delimiter, input_file):
#     # Validate file existence
#     if not os.path.isfile(input_file):
#         raise FileNotFoundError(f"File not found: {input_file}")
    
#     # Validate file extension
#     if not input_file.lower().endswith(".txt"):
#         raise ValueError("The file must have a .txt extension")
    
#     try:
#         # Auto-detect delimiter if not provided
#         if delimiter is None:
#             # Try reading with common delimiters
#             try:
#                 df = pd.read_csv(input_file)  # Default: comma
#             except pd.errors.ParserError:
#                 df = pd.read_csv(input_file, delimiter="\t")  # Try tab
#         else:
#             df = pd.read_csv(input_file, delimiter=delimiter)
        
#         return df
    
#     except Exception as e:
#         raise RuntimeError(f"Error reading file: {e}")

if __name__ == "__main__":
    main()