#!/bin/sh

set -e

# Parse inputs
START_DIR="${1:-"."}"
BASE_DIR="${2:-""}"
DEBUG="${3:-"false"}"
QUIET="${4:-"false"}"
SILENT="${5:-"false"}"
SMARTERR_CONFIG_PATTERN="${6:-"**/smarterr.hcl"}"

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

# Find all smarterr.hcl files using the pattern
echo "Searching for smarterr config files with pattern: $SMARTERR_CONFIG_PATTERN"

# Use find to locate smarterr.hcl files
CONFIG_FILES=$(find "$START_DIR" -name "smarterr.hcl" -type f 2>/dev/null || true)

if [ -z "$CONFIG_FILES" ]; then
    echo "No smarterr.hcl files found in directory: $START_DIR"
    echo "Searched with pattern: $SMARTERR_CONFIG_PATTERN"
    exit 1
fi

echo "Found smarterr config files:"
echo "$CONFIG_FILES"
echo ""

# Track overall exit code
OVERALL_EXIT_CODE=0

# Check each config file
echo "$CONFIG_FILES" | while IFS= read -r config_file; do
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
done

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
