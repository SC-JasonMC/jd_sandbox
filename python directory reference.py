# Get directory name:

import os
filepath = r"C:\Users\Jason\Documents\report.xlsx"
directory = os.path.dirname(filepath)
print(directory)  # C:\Users\Jason\Documents

# Get File Name (with extension)

filename = os.path.basename(filepath)
print(filename)  # report.xlsx

# Get File Name (without extension)

name_only = os.path.splitext(filename)[0]
print(name_only)  # report

# Get File Extension

extension = os.path.splitext(filename)[1]
print(extension)  # .xlsx

# Join Paths Safely

new_path = os.path.join(directory, "newfile.xlsx")
print(new_path)  # C:\Users\Jason\Documents\newfile.xlsx

# Normalize Path
# Converts mixed slashes or redundant separators into a clean format:

normalized = os.path.normpath(r"C:/Users//Jason/Documents\\report.xlsx")
print(normalized)  # C:\Users\Jason\Documents\report.xlsx

# Check if Path Exists

os.path.exists(filepath)  # True or False

# Get Absolute Path

abs_path = os.path.abspath("report.xlsx")
print(abs_path)  # Full path to report.xlsx

# List Files in a Directory

files = os.listdir(directory)
print(files)

# Use pathlib (Modern Alternative)

from pathlib import Path

p = Path(filepath)
print(p.parent)       # C:\Users\Jason\Documents
print(p.name)         # report.xlsx
print(p.stem)         # report
print(p.suffix)       # .xlsx

# Pro Tip:
# pathlib is more modern and object-oriented, while os.path is older but still widely used. For new projects, prefer pathlib.