import boto3
import json
import os
import wget
import argparse
import pandas as pd
import numpy as np
from urllib.request import urlopen
from pptx import Presentation
from pptx.enum.shapes import MSO_SHAPE_TYPE
import datetime

excel_input = "C:\\Users\\McleodJ\\OneDrive - SOFTCAT PLC\\Documents\\pytest\\processed_data_NEW_GOOD.xlsx"

df = pd.read_excel(excel_input, sheet_name="Basic Compute")

df['winqty'] = np.where(df['license_code'] == 'Windows', 1, 0)


winsrvqty = df['winqty'].sum()
print(winsrvqty)
