import json
import os

json_dict = {"os": ["ubuntu-latest", "windows-latest", "macos-latest"], "python-version": []}

json_dict["python-version"].append("3.10")
json_dict["python-version"].append("3.11")

with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
    print(f'matrix={json.dumps(json_dict)}', file=fh)