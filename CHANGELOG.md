# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.6.0] September 17, 2026

### Changed
- Bump the pinned `SMARTERR_VERSION` to `v0.10.0` (from `v0.9.0`). The builder
  stays `golang:1.26-alpine3.24`, since smarterr v0.10.0 keeps the `go 1.26`
  directive.

## [v0.5.0] September 17, 2026

### Fixed
- Build the smarterr CLI with a Go 1.26 builder and pin `SMARTERR_VERSION` to a
  released tag instead of `latest`, so a smarterr release that raises its Go
  directive can no longer break the image build for consumers (#10).
- Propagate per-config check failures instead of swallowing them in a pipeline
  subshell (#10).

### Changed
- Move the builder and runtime images to the latest Alpine (`golang:1.26-alpine3.24`
  and `alpine:3.24`).

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
