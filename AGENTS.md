# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A Nix flake-based dotfiles repository managing system configurations across multiple platforms: NixOS (Linux), nix-darwin (macOS), and nix-on-droid (Android).

## Common Commands

```bash
# Rebuild system (uses NH_FLAKE env var pointing to ~/dotfiles)
nh home switch ~/dotfiles           # Home Manager only
nh os switch                        # NixOS (Linux)
nh darwin switch ~/dotfiles         # macOS

# Format Nix files
nix fmt

# Update flake inputs
nix flake update

# Stage new files before build (flakes only see git-tracked files)
git add <new-files>
```

## Architecture

### Directory Structure

```
├── flake.nix           # Entry point: defines inputs, outputs, and all host configurations
├── hosts/              # Per-machine configurations (ox, horse, tiger, snake, monkey, rabbit)
│   └── <host>/
│       ├── config.nix  # System config (imports modules, sets options)
│       └── home.nix    # User config for standalone home-manager
├── modules/
│   ├── nixos/          # NixOS-specific modules (Linux systems)
│   ├── darwin/         # nix-darwin modules (macOS)
│   ├── home-manager/   # User-level modules (cross-platform)
│   └── nix-on-droid/   # Android-specific modules
├── overlays/           # Package overlays (additions, modifications, stable-packages)
└── pkgs/               # Custom package definitions
```

### Module Pattern

All modules follow an enable pattern with `modules.<name>.enable`:

```nix
# In host config:
modules = {
  tailscale.enable = true;
  stylix.enable = true;
};
```

Modules are imported automatically via `outputs.nixosModules`, `outputs.darwinModules`, or `outputs.homeManagerModules` in each host's config.

### Key Flake Outputs

- `nixosConfigurations`: ox (server), horse (server), tiger (desktop)
- `darwinConfigurations`: snake (macOS)
- `nixOnDroidConfigurations`: monkey, rabbit (Android)
- `homeConfigurations`: Standalone home-manager for each host

### Overlays

Three overlay types defined in `overlays/default.nix`:

- `additions`: Custom packages from `pkgs/` directory
- `modifications`: Patched/modified upstream packages
- `stable-packages`: Access via `pkgs.stable.*` for stable channel packages

## Documentation Reference

```bash
man configuration.nix         # NixOS options
man darwin-configuration.nix  # macOS/nix-darwin options (when on Darwin)
man home-configuration.nix    # Home Manager options
man nixvim                    # Nixvim options
```

## Notes

- Username is defined globally in `flake.nix` as `outputs.username = "idjo"`
- New files must be `git add`ed before `nix` commands can see them (flake restriction)
- `pkgs.stable.*` provides packages from nixpkgs-stable channel
