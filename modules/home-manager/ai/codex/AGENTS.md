# Agent Instructions

## Skills

Always use superpower skill

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

Use inline python scripts whenever possible so doesnt leave any temporary files scattered

## Context7

Before doing any tasks always use context7 mcp

## Task Tracking

Use `br` for task tracking
