---
name: nix-debugging
description: Debug Nix build failures, evaluation errors, and configuration issues
---

# Nix Debugging Skill

## Common Error Types

### Evaluation Errors
- Infinite recursion
- Attribute not found
- Type errors

### Build Errors
- Missing dependencies
- Hash mismatches
- Build phase failures

## Debugging Commands

```bash
# Show build log
nix log /nix/store/<hash>-<name>

# Build with verbose output
nix build -L

# Evaluate expression
nix eval --expr '<expr>'

# Show derivation
nix show-derivation <drv>

# Enter build environment
nix develop

# Check flake
nix flake check
```

## Troubleshooting Steps

1. Read the error message carefully
2. Check for typos in attribute names
3. Verify input types match expected types
4. Use `builtins.trace` for debugging
5. Check flake.lock for version issues
