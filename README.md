# check-smarterr-config

A GitHub Action to check [smarterr](https://github.com/YakDriver/smarterr) configuration files in your CI/CD pipeline.

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
      - uses: YakDriver/check-smarterr-config@v1
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
      - uses: YakDriver/check-smarterr-config@v1
        with:
          start-dir: './src'
          base-dir: './configs'
          debug: 'true'
          quiet: 'false'
          silent: 'false'
          smarterr-config-pattern: '**/smarterr.hcl'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `start-dir` | Directory where code using smarterr lives. This is typically where the error occurs. | No | `.` |
| `base-dir` | Parent directory where go:embed is used (optional, but recommended for proper config layering as in the application). If not set, config applies only to the current directory. | No | `""` |
| `debug` | Enable smarterr debug output (even if config fails to load) | No | `false` |
| `quiet` | Only output errors (suppresses merged config and warnings) | No | `false` |
| `silent` | No output, only exit code (non-zero if errors) | No | `false` |
| `smarterr-config-pattern` | Pattern to find smarterr config files | No | `**/smarterr.hcl` |

## How It Works

1. The action searches for all `smarterr.hcl` files in your repository using the specified pattern
2. For each config file found, it runs `smarterr check` with the appropriate flags
3. The action reports success/failure for each config file
4. The overall action fails if any config check fails

## Examples

### Check configs in a specific directory

```yaml
- uses: YakDriver/check-smarterr-config@v1
  with:
    start-dir: './internal/errors'
```

### Use with custom base directory for go:embed

```yaml
- uses: YakDriver/check-smarterr-config@v1
  with:
    start-dir: './pkg/myservice'
    base-dir: './configs'
```

### Silent mode (only exit codes)

```yaml
- uses: YakDriver/check-smarterr-config@v1
  with:
    silent: 'true'
```

### Debug mode for troubleshooting

```yaml
- uses: YakDriver/check-smarterr-config@v1
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
Searching for smarterr config files with pattern: **/smarterr.hcl
Found smarterr config files:
./internal/errors/smarterr.hcl
./pkg/service/smarterr.hcl

Checking smarterr config: ./internal/errors/smarterr.hcl
Config directory: ./internal/errors
✅ Config check passed: ./internal/errors/smarterr.hcl

Checking smarterr config: ./pkg/service/smarterr.hcl
Config directory: ./pkg/service
✅ Config check passed: ./pkg/service/smarterr.hcl

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
