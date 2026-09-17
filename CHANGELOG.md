# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Build the smarterr CLI with a Go 1.26 builder image. smarterr v0.9.0 requires
  Go 1.26, so the previous `golang:1.24` builder failed to install it (Alpine
  can't run the auto-downloaded glibc toolchain). Bumped the builder to
  `golang:1.26-alpine3.24` and the runtime to `alpine:3.24`.

## [v0.3.0] June 30, 2025

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
