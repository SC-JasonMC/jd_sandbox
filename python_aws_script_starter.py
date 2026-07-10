import boto3
import json
import os
import argparse
import datetime

today = datetime
current_date = datetime.date.today().strftime("%d %B %Y")

current_dir = os.getcwd()

def parse_args():
    parser = argparse.ArgumentParser(description="Prompt if argument not provided")
    parser.add_argument("-f", "--input_file", help="Enter input file path ")

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

if __name__ == "__main__":
    main()