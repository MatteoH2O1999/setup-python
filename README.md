# Build and Setup Python

[![CI/CD](https://github.com/MatteoH2O1999/setup-python/actions/workflows/test.yml/badge.svg)](https://github.com/MatteoH2O1999/setup-python/actions/workflows/test.yml)

This action wraps around [actions/setup-python](https://github.com/actions/setup-python) allowing for deprecated CPython versions to be built from source instead of leading to a failure while appearing transparent in all other cases.

## Table of contents

- [Build and Setup Python](#build-and-setup-python)
  - [Table of contents](#table-of-contents)
  - [Basic usage](#basic-usage)
  - [Motivation](#motivation)
    - [But why? It's deprecated: just use a more recent version](#but-why-its-deprecated-just-use-a-more-recent-version)
    - [But why a dedicated action? Just use `ubuntu-20.04` for that 1 job](#but-why-a-dedicated-action-just-use-ubuntu-2004-for-that-1-job)
  - [Guarantees](#guarantees)
  - [Known limits](#known-limits)
  - [Performance](#performance)
  - [Security guarantees](#security-guarantees)
  - [Inputs](#inputs)
    - [allow-build input](#allow-build-input)
  - [Outputs](#outputs)
  - [Contributing](#contributing)

## Basic usage

For a more complete view on the actions see [action.yml](action.yml) or look in the [Inputs](#inputs) and [Outputs](#outputs) sections.
In general you could replace the original action with this one and it should already work (all its supported inputs are also supported in this one):

```yaml
- uses: MatteoH2O1999/setup-python@v1
  with:
    python-version: '3.6'
    cache: pip
```

But if you wish for a more optimized experience you could use inputs exclusive to this action:

```yaml
- uses: MatteoH2O1999/setup-python@v1
  with:
    python-version: '3.6'
    allow-build: info
    cache-build: true
    cache: pip
```

## Motivation

Since the replacement of `ubuntu-20.04` with `ubuntu-22.04` runner images [actions/setup-python](https://github.com/actions/setup-python) no longer supports `Python 3.6` for the `ubuntu-latest` label.
This broke a large number of pipelines as Python 3.6 is still widely used.

This made apparent that a way to support deprecated versions was needed.

### But why? It's deprecated: just use a more recent version

Yes, in a perfect world that would be the go to solution.
Unfortunately, we do not live in that world, so we can't always choose our dependencies.
In fact, I would be willing to bet that most deprecated dependencies are there despite the developers, not because of them.
That is why this action came about: to offer an easier way to continue supporting deprecated builds even if github does not anymore.

### But why a dedicated action? Just use `ubuntu-20.04` for that 1 job

Once again, that is possible, but that is

1. not good practice as editing the main job matrix will not edit the "special" one;
2. a pain to maintain as each new deprecated version needs another job to be created.

## Guarantees

The objective of this action is to guarantee that for every major Python version starting from `2.7` at least one specific version can be successfully installed on the `...-latest` images using the default architecture.

TLDR: If you use the major version specification (`3.6` instead of `3.6.5`) without specifying the architecture as shown in [Basic usage](#basic-usage) this action is guaranteed to work (hopefully...😉) on all the `...-latest` labels.

## Known limits

This action at the moment does not support:

- installing multiple Python versions;
- building PyPy from source;
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
|check-latest|Set this option if you want the action to check for the latest available version that satisfies the version spec (temporarily disabled).|`false`, `true`|`false`|
|token|The token used to authenticate when fetching Python distributions from [actions/python-versions](https://github.com/actions/python-versions). When running this action on github.com, the default value is sufficient. When running on GHES, you can pass a personal access token for github.com if you are experiencing rate limiting.|example: `TokenString`|`github.token`|
|cache-dependency-path|Used to specify the path to dependency files. Supports wildcards or a list of file names for caching multiple dependencies.|example: `path/to/dependency/files`|`''`|
|update-environment|Set this option if you want the action to update environment variables.|`true`, `false`|`true`|
|**cache-build**|Whether to cache the built Python distribution to speed up successive runs.|`true`, `false`|`false`|
|**allow-build**|Set the behavior of the action when [actions/setup-python](https://github.com/actions/setup-python) fails and has to be built from source.|`allow`, `info`, `warn`, `error`|`warn`|

### allow-build input

This action can apply for different behaviors when it tries to install a CPython version not supported by [actions/setup-python](https://github.com/actions/setup-python):

- `error` this emulates [actions/setup-python](https://github.com/actions/setup-python) and throws an error (thus failing the job) if the Python version cannot be downloaded from [actions/python-versions](https://github.com/actions/python-versions);
- `warn`(default) this will proceed to build the specified version of CPython but will still throw a warning. This was chosen as the default behavior as the user may not know a deprecated version has been requested;
- `info` this will build from source and only print to the logs the fact that a specific Python version will be built from source;
- `allow` same as `info` but does not even print to logs the fact that CPython will be built from source.

## Outputs

This action will emit the following outputs:

|Output name|Description|
|-----------|-----------|
|python-version|The installed Python or PyPy version. Useful when given a version range as input.|
|cache-hit|A boolean value to indicate a cache entry was found (for pip, pipenv and poetry).|
|python-path|The absolute path to the Python or PyPy executable.|

## Contributing

This action is pretty much only a wrapper for a javascript action.
Any issue you might encounter with this action is probably caused by [MatteoH2O1999/build-and-install-python](https://github.com/MatteoH2O1999/build-and-install-python).
If you wish to contribute, you should do so there.
