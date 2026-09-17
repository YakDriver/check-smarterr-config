#!/bin/sh

set -e

# Parse inputs
START_DIR="${1:-"."}"
BASE_DIR="${2:-""}"
DEBUG="${3:-"false"}"
QUIET="${4:-"false"}"
SILENT="${5:-"false"}"

# Wrapper log helpers that honor silent/quiet for the action's OWN output
# (distinct from the smarterr CLI's output, controlled by the flags below):
#   log_info - informational/success lines; suppressed by --silent or --quiet
#   log_err  - failure lines; suppressed only by --silent (still shown under
#              --quiet, whose contract is "only output errors")
log_info() {
    if [ "$SILENT" = "true" ] || [ "$QUIET" = "true" ]; then
        return 0
    fi
    printf '%s\n' "$*"
}

log_err() {
    if [ "$SILENT" = "true" ]; then
        return 0
    fi
    printf '%s\n' "$*"
}

# Build the smarterr flag list as positional parameters rather than a single
# space-joined string, so flag values containing whitespace (e.g. a base-dir
# with spaces) are preserved as single arguments instead of being word-split.
set --
if [ "$DEBUG" = "true" ]; then
    set -- "$@" --debug
fi
if [ "$QUIET" = "true" ]; then
    set -- "$@" --quiet
fi
if [ "$SILENT" = "true" ]; then
    set -- "$@" --silent
fi
if [ -n "$BASE_DIR" ]; then
    set -- "$@" --base-dir="$BASE_DIR"
fi

# Change to the working directory. Guard against an unset/empty GITHUB_WORKSPACE
# (e.g. running the image outside GitHub Actions) so failure is explicit rather
# than a cryptic `cd` error under `set -e`.
cd "${GITHUB_WORKSPACE:-.}" 2>/dev/null || {
    # Replace cd's raw stderr with a clearer message, and honor silent mode
    # (no wrapper output, only the exit code).
    [ "$SILENT" = "true" ] || echo "GITHUB_WORKSPACE is not set to a valid directory" >&2
    exit 1
}

# Scope discovery to the layering root. base-dir is the go:embed parent that
# smarterr uses as the root for config layering, so when it's set we search
# there, falling back to start-dir otherwise. This excludes stray smarterr.hcl
# files *outside* that root (elsewhere in the repo) that would otherwise be
# checked and could fail the action. Note: it does not inspect go:embed
# patterns, so every smarterr.hcl *under* the root is still discovered.
SEARCH_DIR="${BASE_DIR:-$START_DIR}"

log_info "Searching for smarterr.hcl files under: $SEARCH_DIR"

# Use find to locate smarterr.hcl files (exact file name, matching smarterr's
# own discovery, which recognizes only files named exactly "smarterr.hcl").
CONFIG_FILES=$(find "$SEARCH_DIR" -name "smarterr.hcl" -type f 2>/dev/null || true)

if [ -z "$CONFIG_FILES" ]; then
    log_err "No smarterr.hcl files found under: $SEARCH_DIR"
    exit 1
fi

log_info "Found these smarterr config files:"
log_info "$CONFIG_FILES"
log_info ""

# Track overall exit code
OVERALL_EXIT_CODE=0

# Check each config file. Read via a here-document rather than a pipe so the
# loop runs in the current shell; in a pipeline it runs in a subshell and the
# exit code below never sees the failure.
while IFS= read -r config_file; do
    if [ -n "$config_file" ]; then
        config_dir=$(dirname "$config_file")
        log_info "Checking smarterr config: $config_file"
        log_info "Config directory: $config_dir"

        # Run smarterr check with the config directory as start-dir. "$@" carries
        # the pre-built flags, each preserved as a distinct argument.
        if smarterr check --start-dir="$config_dir" "$@"; then
            log_info "✅ Config check passed: $config_file"
        else
            EXIT_CODE=$?
            OVERALL_EXIT_CODE=$EXIT_CODE
            log_err "❌ Config check failed: $config_file (exit code: $EXIT_CODE)"
        fi
        log_info ""
    fi
done <<EOF
$CONFIG_FILES
EOF

if [ $OVERALL_EXIT_CODE -eq 0 ]; then
    log_info "🎉 All smarterr config checks passed!"
else
    log_err "💥 One or more smarterr config checks failed!"
fi

exit $OVERALL_EXIT_CODE
