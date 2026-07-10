# name = input("What's your name? ")
# print(name)
import argparse
import datetime

today = datetime
current_date = datetime.date.today().strftime("%d %B %Y")

def parse_args():
    parser = argparse.ArgumentParser(description="Example: Prompt if argument not provided")

    parser.add_argument("-f", "--input_file", help="Enter input file path")
    parser.add_argument("-n", "--assessor_name", help="What's your name?")
    parser.add_argument("-r", "--assessor_role", help="What's your job title?")

    args = parser.parse_args()

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

    # If name was not provided, prompt the user
    if not args.assessor_name:
        try:
            args.assessor_name = input("What's your name? ").strip()
            if not args.assessor_name:
                raise ValueError("Name cannot be empty.")
        except (EOFError, KeyboardInterrupt):
            print("\nInput cancelled.")
            exit(1)
        except ValueError as e:
            print(f"Error: {e}")
            exit(1)

    # If role was not provided, prompt the user
    if not args.assessor_role:
        try:
            args.assessor_role = input("What's your job title? ").strip()
            if not args.assessor_role:
                raise ValueError("Tob title cannot be empty.")
        except (EOFError, KeyboardInterrupt):
            print("\nInput cancelled.")
            exit(1)
        except ValueError as e:
            print(f"Error: {e}")
            exit(1)

    cover_slide_info = (f"{args.assessor_name}, {args.assessor_role}\n{current_date}")

    return cover_slide_info

if __name__ == "__main__":
    parse_args()