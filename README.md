# auto-gofmt

[![CodeFactor](https://www.codefactor.io/repository/github/iamnotaturtle/auto-gofmt/badge)](https://www.codefactor.io/repository/github/iamnotaturtle/auto-gofmt)

A GitHub action for auto formatting your golang code using [gofumpt](https://github.com/mvdan/gofumpt)

## Usage

### Parameters

| Parameter | Required | Default | Description |
| - | :-: | :-: | - |
| commit_message | :x: | `"Formatting go code"` | Custom git commit message, will be ignored if used with `same_commit` |
| same_commit | :x: | `false` | Update the current commit instead of creating a new one, created by [Joren Broekema](https://github.com/jorenbroekema), this command works only with the checkout action set to fetch depth '0' (see example 1)  |
| commit_options | :x: | - | Custom git commit options |
| push_options | :x: | - | Custom git push options |
| formatter_options | :x: | `-l -w .` | `gofumpt` options (by default it applies to the whole repository) |
| file_pattern | :x: | `*` | Custom git add file pattern, can't be used with only_changed! |
| dry | :x: | `false` | Runs the action in dry mode. Files wont get changed and the action fails if there are unformatted files. |
| only_changed | :x: | `false` | Only format changed files, can't be used with file_pattern! This command works only with the checkout action set to fetch depth '0' (see example 1)|
| github_token | :x: | `${{ github.token }}` | The default [GITHUB_TOKEN](https://docs.github.com/en/actions/reference/authentication-in-a-workflow#about-the-github_token-secret) or a [Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)

> Note: using the same_commit option may lead to problems if other actions are relying on the commit being the same before and after the prettier action has ran. Keep this in mind.

### Example Config

#### Example 1 (using the only_changed or same_commit option on PR)
```yaml
name: Continuous Integration

on:
  pull_request:
    branches: [master]

jobs:
  prettier:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v2
      with:
        # Make sure the actual branch is checked out when running on pull requests
        ref: ${{ github.head_ref }}
        # This is important to fetch the changes to the previous commit
        fetch-depth: 0

    - name: Format code
      uses: iamnotaturtle/auto-gofmt@v1.0
      with:
        # This part is also where you can pass other options, for example:
        only_changed: True
```

More documentation for writing a workflow can be found [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions).

## References
Thanks to these great projects for helping me out:
* [GitHub Prettier Action](https://github.com/creyD/prettier_action)
* [auto-go-format](https://github.com/sladyn98/auto-go-format)