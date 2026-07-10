import os
import argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--input_file", help="Enter input file path")
output_file_path = "C:\\Users\\McleodJ\\SOFTCAT PLC\\Professional Services Digital Workspace Team - Customer documentation\\Staysure (AM - Alexander Keveren)\\AWS Migration\\MAP Assess\\Outputs\\test_output.xlsx"
compute_headers = ["Server Name", "Recommended Instance"] # The headers needed to start off. The script adds the rest and builds a new CSV.

args = parser.parse_args()

input_file_path = args.input_file
# input_file_path = "C:\\Users\\McleodJ\\SOFTCAT PLC\\Professional Services Digital Workspace Team - Customer documentation\\Staysure (AM - Alexander Keveren)\\AWS Migration\\MAP Assess\\Outputs\\Dashboard-All-Infrastructures-OLA-2---Workload--On-Demand.xlsx"

compute_data = pd.read_excel(input_file_path, sheet_name="Compute", skiprows=1, usecols=compute_headers)
basic_instance_types = list(set(compute_data['Recommended Instance']))
for basic_instance_type in basic_instance_types:
    print(basic_instance_type)

