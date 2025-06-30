# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of check-smarterr-config GitHub Action
- Docker-based action that checks smarterr configuration files
- Support for all smarterr check command flags:
  - `start-dir`: Directory where code using smarterr lives
  - `base-dir`: Parent directory where go:embed is used
  - `debug`: Enable smarterr debug output
  - `quiet`: Only output errors
  - `silent`: No output, only exit codes
- Automatic discovery of all `smarterr.hcl` files in repository
- Comprehensive error reporting and validation
- Example workflows and documentation
