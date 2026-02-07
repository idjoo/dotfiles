# Module Reference

This document provides a comprehensive reference for all modules in the dotfiles repository, organized by platform.

## Table of Contents

- [Module Convention](#module-convention)
- [Home Manager Modules](#home-manager-modules)
  - [AI & Development](#ai--development)
  - [Editors](#editors)
  - [Shells](#shells)
  - [Terminals](#terminals)
  - [Browsers](#browsers)
  - [Git Tools](#git-tools)
  - [CLI Utilities](#cli-utilities)
  - [Security](#security)
  - [Desktop Environment](#desktop-environment)
  - [Theming](#theming)
- [NixOS Modules](#nixos-modules)
- [Darwin Modules](#darwin-modules)
- [nix-on-droid Modules](#nix-on-droid-modules)

---

## Module Convention

All modules follow a consistent enable pattern:

```nix
# Module structure
{
  options.modules.<name> = {
    enable = lib.mkEnableOption "<name>";
    # Additional options...
  };

  config = lib.mkIf cfg.enable {
    # Configuration applied when enabled
  };
}

# Usage in host config
modules.<name>.enable = true;
```

### Enabling Modules

```nix
# In hosts/<host>/home.nix or config.nix
modules = {
  # Simple enable
  neovim.enable = true;
  zsh.enable = true;

  # With additional options
  git = {
    enable = true;
    email = "your@email.com";
  };

  # Hierarchical options
  utils = {
    enable = true;
    cli.enable = true;
    gui.enable = true;
  };
};
```

---

## Home Manager Modules

Cross-platform user-level modules available on all platforms.

### AI & Development

#### `modules.claude-code`

Anthropic's Claude Code CLI with custom commands, skills, and MCP integration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Claude Code |

**Features:**
- Wrapper script with Anthropic/Google Cloud credentials
- MCP server integration (Context7, Serena, Playwright, Atlassian)
- Custom commands (`/commit`, `/tag`)
- Skills (Playwright automation, Context7 docs, Tmux)
- Lifecycle hooks (session-start, user-prompt-submit, pre-compact, session-end)
- Memory system integration

**Location:** `modules/home-manager/ai/claude-code/`

---

#### `modules.gemini-cli`

Google Gemini CLI tool for AI-powered assistance.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Gemini CLI |

**Location:** `modules/home-manager/ai/gemini-cli/`

---

#### `modules.playwright`

Playwright browser automation with platform-specific browser paths.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Playwright |

**Features:**
- Platform-specific Chromium executable paths (macOS arm64/intel, Linux)
- Environment variables for browser configuration
- MCP server integration ready

**Location:** `modules/home-manager/playwright/`

---

### Editors

#### `modules.neovim`

Nixvim-managed Neovim configuration with 30+ plugins.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Neovim |

**Plugins Included:**
- **LSP**: lsp, lspsaga, codecompanion, avante
- **Completion**: cmp, autopairs
- **Parsing**: treesitter
- **Navigation**: telescope, oil
- **Git**: gitsigns, neogit
- **Debugging**: dap
- **Formatting**: conform
- **UI**: barbar, which-key, indent-blankline, render-markdown
- **Misc**: spider, neoscroll, fidget, lz-n, colorizer, mcphub, rest, kubectl

**Location:** `modules/home-manager/neovim/`

---

### Shells

#### `modules.zsh`

Z shell configuration with Powerlevel10k theme.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Zsh |

**Features:**
- Powerlevel10k instant prompt
- Custom p10k configuration
- Shell integrations (atuin, fzf, direnv, zoxide)

**Location:** `modules/home-manager/zsh/`

---

#### `modules.nushell`

Nu shell configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Nushell |

**Location:** `modules/home-manager/nushell/`

---

### Terminals

#### `modules.ghostty`

Ghostty terminal emulator (macOS recommended).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Ghostty |

**Location:** `modules/home-manager/ghostty/`

---

#### `modules.wezterm`

WezTerm terminal emulator.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable WezTerm |

**Location:** `modules/home-manager/wezterm/`

---

#### `modules.urxvt`

URxvt terminal emulator (Linux).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable URxvt |

**Location:** `modules/home-manager/urxvt/`

---

### Browsers

#### `modules.zen-browser`

Zen Browser configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Zen Browser |

**Location:** `modules/home-manager/zen-browser/`

---

#### `modules.firefox`

Firefox browser configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Firefox |

**Location:** `modules/home-manager/firefox/`

---

#### `modules.qutebrowser`

Qutebrowser keyboard-driven browser.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Qutebrowser |

**Location:** `modules/home-manager/qutebrowser/`

---

### Git Tools

#### `modules.git`

Git version control configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Git |
| `email` | string | - | Git commit email address |

**Features:**
- Includes `gw` (git worktree helper) script
- Configured aliases and settings

**Location:** `modules/home-manager/git/`

---

#### `modules.lazygit`

LazyGit TUI for Git.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable LazyGit |

**Location:** `modules/home-manager/lazygit/`

---

### CLI Utilities

#### `modules.atuin`

Shell history search and sync.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Atuin |

**Location:** `modules/home-manager/atuin/`

---

#### `modules.btop`

Resource monitor TUI.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable btop |

**Location:** `modules/home-manager/btop/`

---

#### `modules.direnv`

Directory-based environment management.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable direnv |

**Location:** `modules/home-manager/direnv/`

---

#### `modules.eza`

Modern `ls` replacement.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable eza |

**Location:** `modules/home-manager/eza/`

---

#### `modules.fzf`

Fuzzy finder.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable fzf |

**Location:** `modules/home-manager/fzf/`

---

#### `modules.zoxide`

Smarter `cd` command.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable zoxide |

**Location:** `modules/home-manager/zoxide/`

---

#### `modules.tmux`

Terminal multiplexer.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable tmux |

**Features:**
- Platform-aware prefix key (Darwin vs Linux)
- Ghostty integration on macOS

**Location:** `modules/home-manager/tmux/`

---

#### `modules.go`

Go programming language configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Go |

**Location:** `modules/home-manager/go/`

---

#### `modules.utils`

Cross-platform utility packages.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable utils module |
| `cli.enable` | bool | `false` | Enable CLI utilities |
| `gui.enable` | bool | `false` | Enable GUI utilities |
| `custom.enable` | bool | `false` | Enable custom utilities |

**Location:** `modules/home-manager/utils/`

---

### Security

#### `modules.ssh`

SSH client configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable SSH |

**Location:** `modules/home-manager/ssh/`

---

#### `modules.gpg`

GPG configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable GPG |

**Location:** `modules/home-manager/gpg/`

---

#### `modules.password-store`

Pass password manager.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable password-store |

**Location:** `modules/home-manager/password-store/`

---

#### `modules.sops`

SOPS secret management (home-manager level).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable SOPS |

**Features:**
- Per-host SSH key selection based on `hostName`
- Age encryption with secrets from `secrets/config.yaml`

**Location:** `modules/home-manager/sops/`

---

### Desktop Environment

#### `modules.herbstluftwm`

Herbstluftwm tiling window manager (Linux).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable herbstluftwm |

**Location:** `modules/home-manager/herbstluftwm/`

---

#### `modules.polybar`

Polybar status bar (Linux).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Polybar |

**Location:** `modules/home-manager/polybar/`

---

#### `modules.dunst`

Dunst notification daemon (Linux).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Dunst |

**Location:** `modules/home-manager/dunst/`

---

#### `modules.rofi`

Rofi application launcher (Linux).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Rofi |

**Location:** `modules/home-manager/rofi/`

---

#### `modules.flameshot`

Flameshot screenshot tool (Linux).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Flameshot |

**Location:** `modules/home-manager/flameshot/`

---

#### `modules.cava`

Audio visualizer (Linux).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable cava |

**Location:** `modules/home-manager/cava/`

---

### Theming

#### `modules.stylix`

System-wide theming with Stylix.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Stylix |

**Features:**
- Base16 theme: Catppuccin Frappe
- Custom color overrides
- Font configuration (DejaVu, RobotoMono, Noto Emoji)
- Consistent theming across terminal, Neovim, and GUI apps

**Location:** `modules/home-manager/stylix/`

---

## NixOS Modules

Linux system-level modules.

### `modules.nix`

Nix daemon and flake configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Nix configuration |

**Features:**
- Flake registration
- Substituters and trusted public keys
- Experimental features (nix-command, flakes)

**Location:** `modules/nixos/nix/`

---

### `modules.nh`

NH (Nix Helper) rebuild tool.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable NH |

**Location:** `modules/nixos/nh/`

---

### `modules.tailscale`

Tailscale VPN.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Tailscale |

**Location:** `modules/nixos/tailscale/`

---

### `modules.ssh`

OpenSSH server.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable SSH server |

**Location:** `modules/nixos/ssh/`

---

### `modules.pipewire`

Audio system.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable PipeWire |

**Location:** `modules/nixos/pipewire/`

---

### `modules.comma`

Nix-shell command wrapper.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable comma |

**Features:**
- Run commands from nixpkgs without installing
- nix-index integration for package discovery

**Location:** `modules/nixos/comma/`

---

### `modules.xremap`

Keyboard remapping.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable xremap |

**Location:** `modules/nixos/xremap/`

---

### `modules.sops`

SOPS system-level secrets.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable SOPS |

**Location:** `modules/nixos/sops/`

---

### `modules.stylix`

NixOS-level Stylix theming.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Stylix |

**Location:** `modules/nixos/stylix/`

---

### `modules.utils`

NixOS system utilities.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable utils |
| `gui.enable` | bool | `false` | Enable GUI packages |
| `custom.enable` | bool | `false` | Enable custom packages |

**Location:** `modules/nixos/utils/`

---

## Darwin Modules

macOS system-level modules.

### `modules.aerospace`

AeroSpace tiling window manager.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable AeroSpace |

**Location:** `modules/darwin/aerospace/`

---

### `modules.homebrew`

Homebrew package manager integration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Homebrew |

**Features:**
- Cask and formula management
- Auto-update on activation
- Declarative package specification

**Location:** `modules/darwin/homebrew/`

---

### `modules.podman`

Podman container runtime.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Podman |

**Location:** `modules/darwin/podman/`

---

### `modules.nix`

Nix daemon configuration for macOS.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Nix configuration |

**Location:** `modules/darwin/nix/`

---

### `modules.comma`

Comma for macOS.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable comma |

**Location:** `modules/darwin/comma/`

---

### `modules.tailscale`

Tailscale for macOS.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Tailscale |

**Location:** `modules/darwin/tailscale/`

---

### `modules.ssh`

SSH for macOS.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable SSH |

**Location:** `modules/darwin/ssh/`

---

### `modules.stylix`

Stylix for macOS.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Stylix |

**Location:** `modules/darwin/stylix/`

---

### `modules.utils`

macOS utilities.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable utils |

**Location:** `modules/darwin/utils/`

---

## nix-on-droid Modules

Android/Termux-specific modules.

### `modules.android-integration`

Termux/Android integration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Android integration |

**Features:**
- Termux command wrappers (am, termux-open, etc.)
- Android-specific environment setup

**Location:** `modules/nix-on-droid/android-integration/`

---

### `modules.utils`

nix-on-droid utilities.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable utils |

**Location:** `modules/nix-on-droid/utils/`

---

## Module Availability Matrix

| Module | NixOS | Darwin | nix-on-droid |
|--------|:-----:|:------:|:------------:|
| **Home Manager** |
| neovim | ✓ | ✓ | ✓ |
| zsh | ✓ | ✓ | ✓ |
| tmux | ✓ | ✓ | ✓ |
| git | ✓ | ✓ | ✓ |
| ssh (client) | ✓ | ✓ | ✓ |
| claude-code | ✓ | ✓ | - |
| ghostty | - | ✓ | - |
| herbstluftwm | ✓ | - | - |
| polybar | ✓ | - | - |
| **System** |
| aerospace | - | ✓ | - |
| homebrew | - | ✓ | - |
| pipewire | ✓ | - | - |
| xremap | ✓ | - | - |
| android-integration | - | - | ✓ |
