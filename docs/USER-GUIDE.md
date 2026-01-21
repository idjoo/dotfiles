# User Guide

This guide covers common operations for managing your Nix dotfiles configuration.

## Table of Contents

- [Quick Reference](#quick-reference)
- [Rebuilding Your System](#rebuilding-your-system)
- [Managing Flake Inputs](#managing-flake-inputs)
- [Adding a New Host](#adding-a-new-host)
- [Creating a New Module](#creating-a-new-module)
- [Managing Secrets with SOPS](#managing-secrets-with-sops)
- [Working with Overlays](#working-with-overlays)
- [Troubleshooting](#troubleshooting)

---

## Quick Reference

### Common Commands

```bash
# Rebuild configurations
nh home switch ~/dotfiles           # Home Manager only
nh os switch ~/dotfiles              # NixOS (Linux)
nh darwin switch ~/dotfiles         # macOS

# Flake management
nix fmt                              # Format all Nix files
nix flake update                     # Update all inputs
nix flake update nixpkgs             # Update specific input
nix flake show                       # Show flake outputs

# Before first build with new files
git add <new-files>                  # Stage new files (required!)
```

### Documentation Commands

```bash
man configuration.nix         # NixOS options
man darwin-configuration.nix  # macOS options
man home-configuration.nix    # Home Manager options
man nixvim                    # Nixvim options
```

---

## Rebuilding Your System

### Home Manager Only

Use when you only need to update user-level configuration:

```bash
nh home switch ~/dotfiles
```

This rebuilds:
- Shell configuration (zsh, aliases)
- Editor configuration (neovim)
- CLI tools (tmux, git, etc.)
- User services

### Full System Rebuild

#### NixOS (Linux)

```bash
nh os switch ~/dotfiles
```

This rebuilds:
- System configuration (NixOS modules)
- Home Manager configuration
- System services (tailscale, ssh, etc.)
- Kernel and boot configuration

#### macOS

```bash
nh darwin switch ~/dotfiles
```

This rebuilds:
- nix-darwin system configuration
- Homebrew casks and formulas
- macOS system preferences
- Home Manager configuration

### Testing Before Applying

To build without switching:

```bash
# NixOS
nix build .#nixosConfigurations.ox.config.system.build.toplevel

# Home Manager
nix build .#homeConfigurations."idjo@snake".activationPackage

# Darwin
nix build .#darwinConfigurations.snake.system
```

### Rollback

```bash
# NixOS: list generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# NixOS: switch to previous
sudo nixos-rebuild switch --rollback

# Home Manager: list generations
home-manager generations

# Home Manager: switch to specific
/nix/store/<hash>-home-manager-generation/activate
```

---

## Managing Flake Inputs

### View Current Inputs

```bash
nix flake metadata
```

### Update All Inputs

```bash
nix flake update
```

### Update Specific Input

```bash
nix flake update nixpkgs
nix flake update home-manager
```

### Pin Input to Specific Version

Edit `flake.nix`:

```nix
inputs = {
  # Pin to specific commit
  nixpkgs.url = "github:nixos/nixpkgs/abc123...";

  # Pin to specific branch
  nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  # Pin to specific tag
  nixpkgs.url = "github:nixos/nixpkgs/24.05";
};
```

### Lock File

The `flake.lock` file tracks exact versions. Commit it to ensure reproducible builds:

```bash
git add flake.lock
git commit -m "chore: update flake.lock"
```

---

## Adding a New Host

### Step 1: Create Host Directory

```bash
mkdir -p hosts/newhostname
```

### Step 2: Create System Configuration

Create `hosts/newhostname/config.nix`:

```nix
{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  # Import platform-specific modules
  imports = [
    outputs.nixosModules  # or outputs.darwinModules
    ./hardware-config.nix # NixOS only
  ];

  # Apply overlays
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.stable-packages
  ];

  nixpkgs.config.allowUnfree = true;

  # Enable system modules
  modules = {
    nix.enable = true;
    nh.enable = true;
    tailscale.enable = true;
    stylix.enable = true;
  };

  # NixOS specific
  networking.hostName = "newhostname";
  system.stateVersion = "24.05";

  # Users
  users.users.idjo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
}
```

### Step 3: Create Home Configuration

Create `hosts/newhostname/home.nix`:

```nix
{
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    outputs.homeManagerModules
  ];

  programs.home-manager.enable = true;

  home = {
    username = "${outputs.username}";
    homeDirectory = "/home/${outputs.username}";  # or /Users/ for macOS
    stateVersion = "24.05";
  };

  # Enable user modules
  modules = {
    # Editor & Shell
    neovim.enable = true;
    zsh.enable = true;

    # Tools
    tmux.enable = true;
    git = {
      enable = true;
      email = "your@email.com";
    };
    ssh.enable = true;

    # AI tooling
    claude-code.enable = true;

    # Utilities
    atuin.enable = true;
    direnv.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
    lazygit.enable = true;

    # Theming
    stylix.enable = true;

    # Utils
    utils = {
      enable = true;
      cli.enable = true;
    };
  };
}
```

### Step 4: Add to flake.nix

Add the new host to `flake.nix`:

```nix
nixosConfigurations = {
  # ... existing hosts

  newhostname = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs rootPath;
    };
    modules = [
      ./hosts/newhostname/config.nix
    ];
  };
};

homeConfigurations = {
  # ... existing configs

  "idjo@newhostname" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsFor.x86_64-linux;  # or aarch64-darwin for macOS
    extraSpecialArgs = {
      inherit inputs outputs rootPath;
      hostName = "newhostname";
    };
    modules = [
      ./hosts/newhostname/home.nix
    ];
  };
};
```

### Step 5: Stage and Build

```bash
# Stage new files (required for flakes)
git add hosts/newhostname

# Build and switch
nh os switch ~/dotfiles  # or nh darwin switch for macOS
```

---

## Creating a New Module

### Step 1: Create Module File

Create `modules/home-manager/mymodule/default.nix`:

```nix
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.mymodule;
in
{
  # Define options
  options.modules.mymodule = {
    enable = lib.mkEnableOption "mymodule";

    # Optional: additional options
    setting = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "Description of setting";
    };

    enableFeature = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable optional feature";
    };
  };

  # Configuration when enabled
  config = lib.mkIf cfg.enable {
    # Install packages
    home.packages = with pkgs; [
      mypackage
    ];

    # Configure programs
    programs.myprogram = {
      enable = true;
      settings = {
        option = cfg.setting;
      };
    };

    # Conditional configuration
    home.file = lib.mkIf cfg.enableFeature {
      ".config/myprogram/extra.conf".text = ''
        extra configuration
      '';
    };
  };
}
```

### Step 2: Add to Module Index

Edit `modules/home-manager/default.nix`:

```nix
{
  imports = [
    ./ai
    ./atuin
    # ... existing imports
    ./mymodule  # Add new module
    ./zsh
  ];

  # ... rest of file
}
```

### Step 3: Enable in Host Configuration

```nix
# In hosts/<host>/home.nix
modules.mymodule = {
  enable = true;
  setting = "custom-value";
  enableFeature = true;
};
```

### Step 4: Stage and Build

```bash
git add modules/home-manager/mymodule
nh home switch ~/dotfiles
```

---

## Managing Secrets with SOPS

### Prerequisites

1. Age key at `~/.config/sops/age/keys.txt`
2. Public key configured in `.sops.yaml`

### View Secret Configuration

```bash
cat .sops.yaml
```

### Edit Secrets

```bash
# Edit encrypted secrets file
sops secrets/config.yaml
```

### Add New Secret

1. Edit `secrets/config.yaml`:

   ```yaml
   ssh:
     idjo: |
       -----BEGIN OPENSSH PRIVATE KEY-----
       ...
       -----END OPENSSH PRIVATE KEY-----
     newkey: |
       -----BEGIN OPENSSH PRIVATE KEY-----
       ...
       -----END OPENSSH PRIVATE KEY-----
   ```

2. Reference in module:

   ```nix
   sops.secrets."ssh/newkey" = {
     sopsFile = "${rootPath}/secrets/config.yaml";
     path = "${config.home.homeDirectory}/.ssh/newkey";
   };
   ```

### Per-Host Secret Selection

The repository uses `hostName` special arg for per-host secrets:

```nix
let
  sshKey = {
    ox = "idjo";
    horse = "devoteam";
    snake = "devoteam";
  }."${hostName}";
in
{
  sops.secrets."ssh/${sshKey}" = { ... };
}
```

---

## Working with Overlays

### Using Stable Packages

Access packages from the stable channel:

```nix
home.packages = [
  pkgs.unstable-package        # From nixpkgs unstable
  pkgs.stable.stable-package   # From nixpkgs-stable (25.05)
];
```

### Adding Custom Package

1. Create package in `pkgs/`:

   ```bash
   mkdir pkgs/mypackage
   ```

2. Create `pkgs/mypackage/default.nix`:

   ```nix
   {
     stdenv,
     fetchFromGitHub,
     ...
   }:
   stdenv.mkDerivation {
     pname = "mypackage";
     version = "1.0.0";

     src = fetchFromGitHub {
       owner = "owner";
       repo = "repo";
       rev = "v1.0.0";
       sha256 = "sha256-...";
     };

     # ... build instructions
   }
   ```

3. Add to `pkgs/default.nix`:

   ```nix
   { pkgs }:
   {
     mypackage = pkgs.callPackage ./mypackage { };
     # ... other packages
   }
   ```

4. Use in configuration:

   ```nix
   home.packages = [ pkgs.mypackage ];
   ```

### Modifying Upstream Package

Add to `overlays/default.nix`:

```nix
modifications = final: prev: {
  # Override package
  somepackage = prev.somepackage.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./path/to/patch.patch
    ];
  });

  # Use package from input
  mcp-hub = inputs.mcp-hub.packages.${prev.stdenv.hostPlatform.system}.default;
};
```

---

## Troubleshooting

### "file not found" During Build

**Cause**: New files not staged in git.

**Solution**:
```bash
git add <new-files>
nh home switch ~/dotfiles
```

### Build Fails with Evaluation Error

**Debug**:
```bash
# Show detailed error
nix build .#homeConfigurations."idjo@snake".activationPackage --show-trace

# Check specific host
nix eval .#nixosConfigurations.ox.config.system.stateVersion
```

### Module Option Not Found

**Check module is imported**:

1. Verify module exists in `modules/home-manager/<name>/default.nix`
2. Verify import in `modules/home-manager/default.nix`
3. Verify `outputs.homeManagerModules` is imported in host config

### Secrets Not Decrypting

**Check SOPS configuration**:

```bash
# Verify age key exists
cat ~/.config/sops/age/keys.txt

# Test decryption
sops -d secrets/config.yaml
```

### Rollback After Bad Build

```bash
# List generations
home-manager generations

# NixOS rollback
sudo nixos-rebuild switch --rollback
```

### Clear Nix Store Space

```bash
# Garbage collect old generations
nix-collect-garbage -d

# Remove old system profiles
sudo nix-collect-garbage -d
```

### Check Which Generation is Active

```bash
# Current system generation
readlink /run/current-system

# Current home-manager generation
readlink ~/.local/state/nix/profiles/home-manager
```

---

## Common Workflows

### Updating System

```bash
# 1. Update flake inputs
nix flake update

# 2. Rebuild system
nh os switch ~/dotfiles  # NixOS
nh darwin switch ~/dotfiles  # macOS

# 3. Commit lock file
git add flake.lock
git commit -m "chore: update flake inputs"
```

### Adding New Tool

```bash
# 1. Find if module exists
ls modules/home-manager/

# 2a. If module exists, enable it
# Edit hosts/<host>/home.nix:
modules.toolname.enable = true;

# 2b. If module doesn't exist, add package directly
# Edit hosts/<host>/home.nix:
home.packages = [ pkgs.toolname ];

# 3. Rebuild
nh home switch ~/dotfiles
```

### Testing Changes

```bash
# Build without switching
nix build .#homeConfigurations."idjo@snake".activationPackage

# Check derivation output
ls -la result/

# Dry-run activation
./result/activate --dry-run
```

### Debugging Module

```bash
# Evaluate specific option
nix eval .#homeConfigurations."idjo@snake".config.modules.neovim.enable

# Show all home packages
nix eval .#homeConfigurations."idjo@snake".config.home.packages --json | jq
```
