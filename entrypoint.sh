#!/bin/sh

set -e

# Parse inputs
START_DIR="${1:-"."}"
BASE_DIR="${2:-""}"
DEBUG="${3:-"false"}"
QUIET="${4:-"false"}"
SILENT="${5:-"false"}"

# Build smarterr command flags
SMARTERR_FLAGS=""

if [ "$DEBUG" = "true" ]; then
    SMARTERR_FLAGS="$SMARTERR_FLAGS --debug"
fi

if [ "$QUIET" = "true" ]; then
    SMARTERR_FLAGS="$SMARTERR_FLAGS --quiet"
fi

if [ "$SILENT" = "true" ]; then
    SMARTERR_FLAGS="$SMARTERR_FLAGS --silent"
fi

if [ -n "$BASE_DIR" ]; then
    SMARTERR_FLAGS="$SMARTERR_FLAGS --base-dir=$BASE_DIR"
fi

# Change to the working directory
cd "$GITHUB_WORKSPACE"

# Scope discovery to the layering root. base-dir is the go:embed parent that
# smarterr uses as the root for config layering, so when it's set we search
# there, falling back to start-dir otherwise. This excludes stray smarterr.hcl
# files *outside* that root (elsewhere in the repo) that would otherwise be
# checked and could fail the action. Note: it does not inspect go:embed
# patterns, so every smarterr.hcl *under* the root is still discovered.
SEARCH_DIR="${BASE_DIR:-$START_DIR}"

echo "Searching for smarterr.hcl files under: $SEARCH_DIR"

# Use find to locate smarterr.hcl files (exact file name, matching smarterr's
# own discovery, which recognizes only files named exactly "smarterr.hcl").
CONFIG_FILES=$(find "$SEARCH_DIR" -name "smarterr.hcl" -type f 2>/dev/null || true)

if [ -z "$CONFIG_FILES" ]; then
    echo "No smarterr.hcl files found under: $SEARCH_DIR"
    exit 1
fi

echo "Found these smarterr config files:"
echo "$CONFIG_FILES"
echo ""

# Track overall exit code
OVERALL_EXIT_CODE=0

# Check each config file. Read via a here-document rather than a pipe so the
# loop runs in the current shell; in a pipeline it runs in a subshell and the
# exit code below never sees the failure.
while IFS= read -r config_file; do
    if [ -n "$config_file" ]; then
        config_dir=$(dirname "$config_file")
        echo "Checking smarterr config: $config_file"
        echo "Config directory: $config_dir"
        
        # Run smarterr check with the config directory as start-dir
        if smarterr check --start-dir="$config_dir" $SMARTERR_FLAGS; then
            if [ "$SILENT" != "true" ]; then
                echo "✅ Config check passed: $config_file"
            fi
        else
            EXIT_CODE=$?
            OVERALL_EXIT_CODE=$EXIT_CODE
            if [ "$SILENT" != "true" ]; then
                echo "❌ Config check failed: $config_file (exit code: $EXIT_CODE)"
            fi
        fi
        echo ""
    fi
done <<EOF
$CONFIG_FILES
EOF

if [ $OVERALL_EXIT_CODE -eq 0 ]; then
    if [ "$SILENT" != "true" ]; then
        echo "🎉 All smarterr config checks passed!"
    fi
else
    if [ "$SILENT" != "true" ]; then
        echo "💥 One or more smarterr config checks failed!"
    fi
fi

exit $OVERALL_EXIT_CODE
