# Nix Conventions

## File Organization

- Use `default.nix` for module entry points
- Keep related configurations in the same directory
- Use descriptive directory names

## Module Structure

- Use `mkEnableOption` for enable flags
- Use `mkOption` with proper types and descriptions
- Prefer `lib.mkIf` for conditional configuration

## Flakes

- Pin inputs in `flake.lock`
- Use `follows` to reduce duplication
- Keep `flake.nix` clean and readable

## Home Manager

- Prefer declarative configuration over imperative
- Use `programs.*` options when available
- Group related settings together
