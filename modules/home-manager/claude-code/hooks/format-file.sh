#!/usr/bin/env bash
# PostToolUse hook: Auto-format files after Claude edits them
# This handles the "last 10%" of formatting that Claude might miss

set -euo pipefail

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" ]] || [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

case "$EXT" in
  nix)
    if command -v nixfmt &>/dev/null; then
      nixfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  js|jsx|ts|tsx|json|css|scss|html|md|yaml|yml)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  sh|bash)
    if command -v shfmt &>/dev/null; then
      shfmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
