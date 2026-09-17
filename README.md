# check-smarterr-config

A GitHub Action to check [smarterr](https://github.com/YakDriver/smarterr) configuration files in your CI/CD pipeline. This action is a thin wrapper around the [smarterr](https://github.com/YakDriver/smarterr) CLI.

## Overview

This action automatically finds and validates all `smarterr.hcl` configuration files in your repository using the `smarterr check` command. It's designed to ensure your smarterr configurations are valid before deployment.

## Usage

### Basic Usage

```yaml
name: Check smarterr configs
on: [push, pull_request]

jobs:
  check-smarterr:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: YakDriver/check-smarterr-config@v0.3.0
```

### Advanced Usage

```yaml
name: Check smarterr configs
on: [push, pull_request]

jobs:
  check-smarterr:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: YakDriver/check-smarterr-config@v0.3.0
        with:
          start-dir: './src'
          base-dir: './configs'
          debug: 'true'
          quiet: 'false'
          silent: 'false'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `start-dir` | Directory where code using smarterr lives. This is typically where the error occurs. | No | `.` |
| `base-dir` | Parent directory where go:embed is used (optional, but recommended for proper config layering as in the application). If not set, config applies only to the current directory. | No | `""` |
| `debug` | Enable smarterr debug output (even if config fails to load) | No | `false` |
| `quiet` | Only output errors (suppresses merged config and warnings) | No | `false` |
| `silent` | No output, only exit code (non-zero if errors) | No | `false` |

## How It Works

1. The action searches for files named `smarterr.hcl`. When `base-dir` is set, it searches under `base-dir` (the root smarterr uses for config layering); otherwise it searches under `start-dir`. This excludes stray `smarterr.hcl` files *outside* that root (elsewhere in the repo) that you didn't intend to validate. It does not inspect your `go:embed` patterns, so every `smarterr.hcl` *under* the root is still checked.
2. For each config file found, it runs `smarterr check` with the appropriate flags
3. The action reports success/failure for each config file
4. The overall action fails if any config check fails

## Examples

### Check configs in a specific directory

```yaml
- uses: YakDriver/check-smarterr-config@v0.3.0
  with:
    start-dir: './internal/errors'
```

### Use with custom base directory for go:embed

```yaml
- uses: YakDriver/check-smarterr-config@v0.3.0
  with:
    start-dir: './pkg/myservice'
    base-dir: './configs'
```

### Silent mode (only exit codes)

```yaml
- uses: YakDriver/check-smarterr-config@v0.3.0
  with:
    silent: 'true'
```

### Debug mode for troubleshooting

```yaml
- uses: YakDriver/check-smarterr-config@v0.3.0
  with:
    debug: 'true'
```

## Output

The action provides clear feedback about:
- Which config files were found
- The result of each config check
- Overall success/failure status

Example output:
```
Searching for smarterr.hcl files under: ./internal
Found these smarterr config files:
./internal/errors/smarterr.hcl
./internal/service/smarterr.hcl

Checking smarterr config: ./internal/errors/smarterr.hcl
Config directory: ./internal/errors
✅ Config check passed: ./internal/errors/smarterr.hcl

Checking smarterr config: ./internal/service/smarterr.hcl
Config directory: ./internal/service
✅ Config check passed: ./internal/service/smarterr.hcl

🎉 All smarterr config checks passed!
```

## Error Handling

- If no `smarterr.hcl` files are found, the action will fail with an appropriate error message
- If any config check fails, the action will fail and report which configs failed
- Exit codes are preserved from the underlying `smarterr check` command

## Requirements

- Your repository must contain one or more `smarterr.hcl` configuration files
- The action requires access to checkout your repository code

## About smarterr

[smarterr](https://github.com/YakDriver/smarterr) is a tool for better error handling in Go applications. It allows you to define structured error configurations that can be validated and checked for consistency.

## License

This project is licensed under the same license as the [smarterr](https://github.com/YakDriver/smarterr) project.
