# Build and Setup Python

[![CI/CD](https://github.com/MatteoH2O1999/setup-python/actions/workflows/test.yml/badge.svg)](https://github.com/MatteoH2O1999/setup-python/actions/workflows/test.yml)
[![Periodic Check](https://github.com/MatteoH2O1999/setup-python/actions/workflows/periodic_check.yml/badge.svg)](https://github.com/MatteoH2O1999/setup-python/actions/workflows/periodic_check.yml)
[![codecov](https://codecov.io/github/MatteoH2O1999/build-and-install-python/branch/master/graph/badge.svg?token=5HU95AOQ8J)](https://codecov.io/github/MatteoH2O1999/build-and-install-python)
![GitHub](https://img.shields.io/github/license/MatteoH2O1999/setup-python)

This action wraps around [actions/setup-python](https://github.com/actions/setup-python) allowing for deprecated CPython versions to be built from source instead of leading to a failure while appearing transparent in all other cases.

## Table of contents

- [Build and Setup Python](#build-and-setup-python)
  - [Table of contents](#table-of-contents)
  - [Basic usage](#basic-usage)
  - [Motivation](#motivation)
  - [Guarantees](#guarantees)
  - [Known limits](#known-limits)
  - [Performance](#performance)
  - [Security guarantees](#security-guarantees)
  - [Inputs](#inputs)
    - [allow-build input](#allow-build-input)
  - [Outputs](#outputs)
  - [FAQ](#faq)
    - [No file in (...) matched to \[\*\*/requirements.txt or \*\*/pyproject.toml\], make sure you have checked out the target repository](#no-file-in--matched-to-requirementstxt-or-pyprojecttoml-make-sure-you-have-checked-out-the-target-repository)
  - [Contributing](#contributing)

## Basic usage

For a more complete view on the actions see [action.yml](action.yml) or look in the [Inputs](#inputs) and [Outputs](#outputs) sections.
In general you could replace the original action with this one and it should already work (all its supported inputs are also supported in this one):

```yaml
- uses: MatteoH2O1999/setup-python@v6
  with:
    python-version: '3.8'
```

But if you wish for a more optimized experience you could use inputs exclusive to this action:

```yaml
- uses: MatteoH2O1999/setup-python@v6
  with:
    python-version: '3.8'
    allow-build: info
    cache-build: true
    cache: pip
```

## Motivation

While initially this action was meant to guarantee a successful build of all CPython versions `2.7`, it has now become too complex to maintain it.

The new objective of this action is to provide a buffer when something gets yanked out by Github, as this will guarantee that if the pair `(label, version)` works, it will keep working.
Older versions may still work, but no effort will be spent in ensuring so.

## Guarantees

The objective of this action is to guarantee that for every major Python version starting from `3.8` at least one specific version can be successfully installed on the `...-latest` images using the default architecture.

TLDR: If you use the major version specification (`3.8` instead of `3.8.5`) without specifying the architecture as shown in [Basic usage](#basic-usage) this action is guaranteed to work (hopefully...😉) on all the `...-latest` labels.

## Known limits

This action at the moment does not support:

- installing multiple Python versions
- building PyPy from source
- building from source in UNIX systems for a different architecture

This actions tries to but does not guarantee to work on any arbitrary pair (`python-version`, `architecture`).

## Performance

The action's performance depends on the runner OS and on whether Python needs to be built, installed, restored from cache or is already installed:

1. Supported by [actions/setup-python](https://github.com/actions/setup-python)
   1. Already installed on runner
      1. `ubuntu-latest` &#8594; ~10s
      2. `windows-latest` &#8594; ~20s
      3. `macos-latest` &#8594; ~10s
   2. Available from [actions/python-versions](https://github.com/actions/python-versions)
      1. `ubuntu-latest` &#8594; ~20s
      2. `windows-latest` &#8594; ~1m
      3. `macos-latest` &#8594; ~30s
2. Not supported by [actions/setup-python](https://github.com/actions/setup-python)
   1. Already cached
      1. `ubuntu-latest` &#8594; ~20s
      2. `windows-latest` &#8594; ~30s
      3. `macos-latest` &#8594; ~30s
   2. Built from source
      1. `ubuntu-latest` &#8594; ~3m30s
      2. `windows-latest` &#8594; ~25m
      3. `macos-latest` &#8594; ~13m

## Security guarantees

This action is composite and uses the original [actions/setup-python](https://github.com/actions/setup-python) and a custom action [MatteoH2O1999/build-and-install-python](https://github.com/MatteoH2O1999/build-and-install-python).
Both are referenced by commit hash in order to provide better security: if you use this action using its commit hash it will be safe from future malicious edits to the tags.

## Inputs

This action supports the following inputs (in bold are the names of the exclusive inputs for this action):

|Input name|Description|Accepted values|Default value|
|----------|-----------|---------------|-------------|
|python-version|Version range or exact version of Python or PyPy to use, using SemVer's version range syntax. Reads from `.python-version` if both this and `python-version-file` are unset.|`pypy3.7`, `pypy-3.9`, `3.5`, `2.7.6`, ...|`None`|
|python-version-file|File containing the Python version to use. Reads from `.python-version` if both this and `python-version` are unset.|`.python-version`, `path/to/python/version`, ...|`None`|
|cache|Used to specify a package manager for caching in the default directory.|`pip`, `pipenv` and `poetry`|`None`|
|architecture|The target architecture of the Python or PyPy interpreter.|`x64`, `x86`, `arm64`, ...|`None`|
|check-latest|Set this option if you want the action to check for the latest available version that satisfies the version spec.|`false`, `true`|`false`|
|token|The token used to authenticate when fetching Python distributions from [actions/python-versions](https://github.com/actions/python-versions). When running this action on github.com, the default value is sufficient. When running on GHES, you can pass a personal access token for github.com if you are experiencing rate limiting.|example: `TokenString`|`github.token`|
|cache-dependency-path|Used to specify the path to dependency files. Supports wildcards or a list of file names for caching multiple dependencies.|example: `path/to/dependency/files`|`''`|
|update-environment|Set this option if you want the action to update environment variables.|`true`, `false`|`true`|
|freethreaded|When 'true', use the freethreaded version of Python.|`true`, `false`|`false`|
|allow-prereleases|When 'true', a version range passed to 'python-version' input will match prerelease versions if no GA versions are found. Only 'x.y' version range is supported for CPython.|`true`, `false`|`false`|
|pip-version|Used to specify the version of pip to install with the Python. Supported format: `major[.minor][.patch]`.|`20.0.0`, `22`|`None`|
|pip-install|Used to specify the packages to install with pip after setting up Python. Can be a requirements file or package names.|`pandas numpy`, `requirements.txt`|`None`|
|**cache-build**|Whether to cache the built Python distribution to speed up successive runs.|`true`, `false`|`false`|
|**allow-build**|Set the behavior of the action when [actions/setup-python](https://github.com/actions/setup-python) fails and has to be built from source.|`allow`, `info`, `warn`, `error`, `force`|`warn`|

### allow-build input

This action can apply for different behaviors when it tries to install a CPython version not supported by [actions/setup-python](https://github.com/actions/setup-python):

- `error` this emulates [actions/setup-python](https://github.com/actions/setup-python) and throws an error (thus failing the job) if the Python version cannot be downloaded from [actions/python-versions](https://github.com/actions/python-versions);
- `warn`(default) this will proceed to build the specified version of CPython but will still throw a warning. This was chosen as the default behavior as the user may not know a deprecated version has been requested;
- `info` this will build from source and only print to the logs the fact that a specific Python version will be built from source;
- `allow` same as `info` but does not even print to logs the fact that CPython will be built from source;
- `force` this will force Python to be built from source regardless of whether [actions/setup-python](https://github.com/actions/setup-python) supports it or not.

## Outputs

This action will emit the following outputs:

|Output name|Description|
|-----------|-----------|
|python-version|The installed Python or PyPy version. Useful when given a version range as input.|
|cache-hit|A boolean value to indicate a cache entry was found (for pip, pipenv and poetry).|
|python-path|The absolute path to the Python or PyPy executable.|

## FAQ

### No file in (...) matched to [**/requirements.txt or **/pyproject.toml], make sure you have checked out the target repository

This is a byproduct of [actions/setup-python](https://github.com/actions/setup-python).
If you wish to cache your pip dependencies, you need to have anywhere in your repository a `requirements.txt` or a `pyproject.toml` file.
The solution in this case is either creating a blank `requirements.txt` file or stop caching pip (in order to do so simply remove `cache: pip` from your `.yml` file).

## Contributing

This action is pretty much only a wrapper for a javascript action.
Any issue you might encounter with this action is probably caused by [MatteoH2O1999/build-and-install-python](https://github.com/MatteoH2O1999/build-and-install-python).
If you wish to contribute, you should do so there.
