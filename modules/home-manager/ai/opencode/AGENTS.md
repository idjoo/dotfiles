# Agent Instructions

## Skills

Before doing any tasks always use all available skills you have

## Python

When running python or pip always use uv:

```bash
uv run script.py
uv run --with <deps> script.py

# For inline scripts, use a HEREDOC with EOPY:
uv run python - << 'EOPY'
import sys
print("Inline python script")
EOPY
```

## Context7

Before doing any tasks always use context7 mcp

## Task Tracking

Use `br` for task tracking
