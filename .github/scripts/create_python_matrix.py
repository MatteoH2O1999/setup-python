import git
import json
import os
import sys
import tempfile

json_dict = {"os": ["ubuntu-latest", "windows-latest", "macos-latest"], "python-version": []}

if sys.argv[1] == 'true':
    json_dict['cache'] = [False, True]

with tempfile.TemporaryDirectory() as temp_dir:
    python_repo = git.Repo.clone_from('https://github.com/python/cpython.git', temp_dir)
    tags = python_repo.tags
    for tag in tags:
        if not any(substring in tag.name for substring in ['a', 'b', 'c', 'rc', '-']):
            if tag.name.count('v') > 0:
                short_tag = tag.name.replace('v', '')
                while short_tag.count('.') > 1:
                    short_tag = short_tag[:-1]
                splits = short_tag.split('.')
                major = int(splits[0])
                minor = int(splits[1])
                if major == 3 and minor >= 8 and short_tag not in json_dict['python-version']:
                    json_dict['python-version'].append(short_tag)

with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
    print(f'matrix={json.dumps(json_dict)}', file=fh)