# Architecture Documentation

This document provides a detailed technical overview of the dotfiles repository architecture, including system diagrams, data flows, and design patterns.

## Table of Contents

- [System Overview](#system-overview)
- [Flake Architecture](#flake-architecture)
- [Module System](#module-system)
- [Host Configuration Flow](#host-configuration-flow)
- [Cross-Platform Abstractions](#cross-platform-abstractions)
- [Overlay System](#overlay-system)
- [Secret Management](#secret-management)

---

## System Overview

### High-Level Architecture

```mermaid
graph TB
    subgraph "Flake Entry Point"
        F[flake.nix]
    end

    subgraph "Inputs"
        NP[nixpkgs]
        HM[home-manager]
        ND[nix-darwin]
        NOD[nix-on-droid]
        ST[stylix]
        NV[nixvim]
        SOPS[sops-nix]
        MCP[mcp-hub]
    end

    subgraph "Outputs"
        NC[nixosConfigurations]
        DC[darwinConfigurations]
        NDC[nixOnDroidConfigurations]
        HC[homeConfigurations]
        MOD[*Modules]
        OV[overlays]
        PKG[packages]
    end

    subgraph "Hosts"
        OX[ox<br/>NixOS Server]
        HORSE[horse<br/>NixOS Server]
        TIGER[tiger<br/>NixOS Desktop]
        SNAKE[snake<br/>macOS]
        MONKEY[monkey<br/>Android]
        RABBIT[rabbit<br/>Android]
    end

    NP --> F
    HM --> F
    ND --> F
    NOD --> F
    ST --> F
    NV --> F
    SOPS --> F
    MCP --> F

    F --> NC
    F --> DC
    F --> NDC
    F --> HC
    F --> MOD
    F --> OV
    F --> PKG

    NC --> OX
    NC --> HORSE
    NC --> TIGER
    DC --> SNAKE
    NDC --> MONKEY
    NDC --> RABBIT
```

### Platform Distribution

```mermaid
pie title Host Distribution by Platform
    "NixOS (Linux)" : 3
    "nix-darwin (macOS)" : 1
    "nix-on-droid (Android)" : 2
```

---

## Flake Architecture

### Input Dependencies

```mermaid
graph LR
    subgraph "Core"
        NP[nixpkgs<br/>unstable]
        NPS[nixpkgs-stable<br/>25.05]
        HM[home-manager]
    end

    subgraph "Platform"
        ND[nix-darwin]
        NOD[nix-on-droid]
    end

    subgraph "Features"
        ST[stylix<br/>theming]
        NV[nixvim<br/>neovim]
        SOPS[sops-nix<br/>secrets]
        XR[xremap<br/>keyboard]
    end

    subgraph "External"
        NUR[NUR]
        ZB[zen-browser]
        MCP[mcp-hub]
        MCPN[mcphub-nvim]
    end

    NP --> HM
    NP --> ND
    NP --> NOD
    NP --> ST
    NP --> NV
    NP --> SOPS
    NP --> XR
    NP --> ZB
```

### Flake Outputs Structure

```nix
outputs = {
  # Global username
  username = "idjo";

  # Package outputs
  packages = { ... };        # Custom packages per system
  formatter = { ... };       # nixfmt per system
  overlays = { ... };        # Package overlays

  # Module outputs (auto-imported by hosts)
  nixosModules = { ... };
  homeManagerModules = { ... };
  darwinModules = { ... };
  nixOnDroidModules = { ... };

  # Configuration outputs
  nixosConfigurations = {
    ox = { ... };
    horse = { ... };
    tiger = { ... };
  };

  darwinConfigurations = {
    snake = { ... };
  };

  nixOnDroidConfigurations = {
    monkey = { ... };
    rabbit = { ... };
  };

  homeConfigurations = {
    "idjo@ox" = { ... };
    "idjo@horse" = { ... };
    "idjo@tiger" = { ... };
    "idjo@snake" = { ... };
  };
};
```

---

## Module System

### Module Hierarchy

```mermaid
graph TB
    subgraph "modules/"
        subgraph "home-manager/"
            AI[ai/]
            NV[neovim/]
            ZSH[zsh/]
            TMUX[tmux/]
            UTILS[utils/]
            OTHER[... 40+ modules]
        end

        subgraph "nixos/"
            NIX_N[nix/]
            NH[nh/]
            TS[tailscale/]
            PW[pipewire/]
        end

        subgraph "darwin/"
            NIX_D[nix/]
            HB[homebrew/]
            AS[aerospace/]
            PM[podman/]
        end

        subgraph "nix-on-droid/"
            ANDROID[android-integration/]
            UTILS_A[utils/]
        end
    end

    subgraph "AI Modules"
        CC[claude-code/]
        GC[gemini-cli/]
        MCP[mcp/]
    end

    AI --> CC
    AI --> GC
    AI --> MCP
```

### Module Enable Pattern

Every module follows this consistent structure:

```mermaid
graph LR
    subgraph "Module Structure"
        O[options.modules.X.enable]
        C[config = mkIf cfg.enable]
    end

    subgraph "Host Config"
        E[modules.X.enable = true]
    end

    E --> O
    O --> C
```

**Implementation Pattern:**

```nix
{ lib, config, pkgs, ... }:
let
  cfg = config.modules.mymodule;
in
{
  # 1. Declare options under modules namespace
  options.modules.mymodule = {
    enable = lib.mkEnableOption "mymodule";

    # Optional: additional configuration options
    setting = lib.mkOption {
      type = lib.types.str;
      default = "value";
      description = "Description of setting";
    };
  };

  # 2. Configuration only applied when enabled
  config = lib.mkIf cfg.enable {
    # Actual configuration here
    home.packages = [ pkgs.somepackage ];

    programs.someprogram = {
      enable = true;
      setting = cfg.setting;
    };
  };
}
```

### Module Auto-Import Chain

```mermaid
sequenceDiagram
    participant F as flake.nix
    participant H as hosts/snake/home.nix
    participant M as modules/home-manager/default.nix
    participant S as modules/home-manager/*/default.nix

    F->>H: extraSpecialArgs (inputs, outputs, rootPath, hostName)
    H->>M: imports = [outputs.homeManagerModules]
    M->>S: imports = [./ai, ./neovim, ./zsh, ...]
    S-->>H: All options available
    H->>S: modules.neovim.enable = true
    S-->>H: Config applied via mkIf
```

---

## Host Configuration Flow

### NixOS Host Build Flow

```mermaid
flowchart TB
    subgraph "Build Command"
        CMD[nh os switch ~/dotfiles]
    end

    subgraph "Flake Resolution"
        FN[flake.nix]
        NC[nixosConfigurations.hostname]
    end

    subgraph "Host Config"
        HC[hosts/hostname/config.nix]
        HW[hardware-config.nix]
    end

    subgraph "Modules"
        NM[nixosModules]
        SM[System modules applied]
    end

    subgraph "Home Manager"
        HMC[home.nix]
        HMM[homeManagerModules]
        UM[User modules applied]
    end

    subgraph "Result"
        SYS[/etc/nixos/configuration]
        USER[~/.config/*]
    end

    CMD --> FN
    FN --> NC
    NC --> HC
    HC --> HW
    HC --> NM
    NM --> SM

    HC -.->|"home-manager.users.idjo"| HMC
    HMC --> HMM
    HMM --> UM

    SM --> SYS
    UM --> USER
```

### Special Args Propagation

```mermaid
graph TB
    subgraph "flake.nix defines"
        IA[inputs - all flake inputs]
        OA[outputs - all flake outputs]
        RP[rootPath - repo root ./.]
        HN[hostName - machine name]
    end

    subgraph "Passed to Configurations"
        SA[specialArgs / extraSpecialArgs]
    end

    subgraph "Available in Modules"
        M1[config.nix]
        M2[home.nix]
        M3[Any module]
    end

    IA --> SA
    OA --> SA
    RP --> SA
    HN --> SA

    SA --> M1
    SA --> M2
    SA --> M3
```

---

## Cross-Platform Abstractions

### Platform Detection Pattern

```mermaid
flowchart TD
    subgraph "Detection"
        D{pkgs.stdenv.isDarwin?}
    end

    subgraph "Darwin Path"
        DP[macOS-specific config]
    end

    subgraph "Linux Path"
        LP[Linux-specific config]
    end

    D -->|true| DP
    D -->|false| LP
```

**Examples in Code:**

```nix
# Rebuild command alias
rebuild = if pkgs.stdenv.isDarwin
  then "${pkgs.nh}/bin/nh darwin switch ~/Dotfiles"
  else "${pkgs.nh}/bin/nh os switch";

# Tmux prefix key
prefix = if pkgs.stdenv.isDarwin && config.programs.ghostty.enable
  then "ƒ"
  else "M-f";

# Playwright browser path
executablePath = if pkgs.stdenv.isDarwin
  then "${pkgs.playwright-driver.browsers}/chromium-.../chrome-mac-arm64/..."
  else "${pkgs.playwright-driver.browsers}/chromium-.../chrome-linux/chrome";
```

### Module Availability by Platform

```mermaid
graph TB
    subgraph "Cross-Platform (home-manager)"
        CP[neovim, zsh, tmux, git, ssh, atuin, fzf, lazygit, ...]
    end

    subgraph "NixOS Only"
        NO[pipewire, xremap, herbstluftwm, polybar, ...]
    end

    subgraph "Darwin Only"
        DO[aerospace, homebrew, podman]
    end

    subgraph "nix-on-droid Only"
        NDO[android-integration]
    end

    CP --> OX[ox]
    CP --> HORSE[horse]
    CP --> TIGER[tiger]
    CP --> SNAKE[snake]

    NO --> OX
    NO --> HORSE
    NO --> TIGER

    DO --> SNAKE

    NDO --> MONKEY[monkey]
    NDO --> RABBIT[rabbit]
```

---

## Overlay System

### Overlay Types and Flow

```mermaid
flowchart LR
    subgraph "overlays/default.nix"
        ADD[additions<br/>Custom packages]
        MOD[modifications<br/>Patched packages]
        STB[stable-packages<br/>Stable channel]
    end

    subgraph "pkgs/"
        P1[android-unpinner]
        P2[dank-mono-nerdfont]
        P3[httpgenerator]
        P4[gam]
    end

    subgraph "Inputs"
        MH[mcp-hub]
        MN[mcphub-nvim]
        NPS[nixpkgs-stable]
    end

    subgraph "Result"
        PKG[pkgs.*]
        SPKG[pkgs.stable.*]
    end

    P1 --> ADD
    P2 --> ADD
    P3 --> ADD
    P4 --> ADD

    MH --> MOD
    MN --> MOD

    NPS --> STB

    ADD --> PKG
    MOD --> PKG
    STB --> SPKG
```

### Overlay Implementation

```nix
# overlays/default.nix
{ inputs }:
{
  # Custom packages from pkgs/ directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # Modified/patched upstream packages
  modifications = final: prev: {
    mcp-hub = inputs.mcp-hub.packages.${prev.stdenv.hostPlatform.system}.default;
    mcphub-nvim = inputs.mcphub-nvim.packages.${prev.stdenv.hostPlatform.system}.default;
  };

  # Access stable channel via pkgs.stable.*
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
```

---

## Secret Management

### SOPS Architecture

```mermaid
flowchart TB
    subgraph "Encryption"
        AGE[age key<br/>~/.config/sops/age/keys.txt]
    end

    subgraph "Configuration"
        SOPS[.sops.yaml<br/>Defines rules & recipients]
    end

    subgraph "Secrets"
        SEC[secrets/config.yaml<br/>Encrypted YAML]
    end

    subgraph "Runtime"
        DEC[Decrypted at activation<br/>/run/secrets/*]
    end

    subgraph "Per-Host Keys"
        OX_KEY[ox: idjo SSH key]
        HORSE_KEY[horse: devoteam SSH key]
        SNAKE_KEY[snake: devoteam SSH key]
    end

    AGE --> SOPS
    SOPS --> SEC
    SEC --> DEC

    DEC --> OX_KEY
    DEC --> HORSE_KEY
    DEC --> SNAKE_KEY
```

### Host-Specific Secret Selection

```nix
# In sops module
let
  sshKey = {
    ox = "idjo";
    horse = "devoteam";
    snake = "devoteam";
  }."${hostName}";
in
{
  sops.secrets."ssh/${sshKey}" = {
    sopsFile = "${rootPath}/secrets/config.yaml";
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
  };
}
```

---

## Neovim Plugin Architecture

### Plugin Organization

```mermaid
graph TB
    subgraph "modules/home-manager/neovim/"
        DN[default.nix<br/>Main module]
        OPT[options.nix<br/>Editor settings]
        KM[keymaps.nix<br/>Key bindings]
        AC[autocommands.nix<br/>Autocmds]
        PL[plugins/]
    end

    subgraph "plugins/"
        LSP[lsp.nix]
        CMP[cmp.nix]
        TS[treesitter.nix]
        TEL[telescope.nix]
        AI[codecompanion.nix, avante.nix]
        GIT[gitsigns.nix, neogit.nix]
        UI[barbar.nix, which-key.nix, ...]
        MORE[... 20+ more]
    end

    DN --> OPT
    DN --> KM
    DN --> AC
    DN --> PL

    PL --> LSP
    PL --> CMP
    PL --> TS
    PL --> TEL
    PL --> AI
    PL --> GIT
    PL --> UI
    PL --> MORE
```

---

## AI/MCP Integration

### Claude Code Architecture

```mermaid
graph TB
    subgraph "Claude Code Module"
        CC[modules/home-manager/ai/claude-code/]
        WRAP[Wrapper with env vars]
        CFG[settings.json]
    end

    subgraph "Commands"
        COMMIT[commit.md]
        TAG[tag.md]
    end

    subgraph "Skills"
        CTX7[context7/]
        PW[playwright/]
        TMUX[tmux/]
    end

    subgraph "Hooks"
        START[session-start]
        PROMPT[user-prompt-submit]
        COMPACT[pre-compact]
        END[session-end]
    end

    subgraph "MCP Servers"
        MCP_CTX[context7]
        MCP_SER[serena]
        MCP_ATL[atlassian]
        MCP_PW[playwright]
    end

    CC --> WRAP
    CC --> CFG
    CC --> COMMIT
    CC --> TAG
    CC --> CTX7
    CC --> PW
    CC --> TMUX
    CC --> START
    CC --> PROMPT
    CC --> COMPACT
    CC --> END

    CFG --> MCP_CTX
    CFG --> MCP_SER
    CFG --> MCP_ATL
    CFG --> MCP_PW
```

---

## Build & Deployment Flow

### Complete Build Pipeline

```mermaid
sequenceDiagram
    participant U as User
    participant NH as nh (nix helper)
    participant NIX as Nix
    participant FLAKE as flake.nix
    participant STORE as Nix Store
    participant SYS as System

    U->>NH: nh os switch / nh home switch
    NH->>NIX: nix build .#configuration
    NIX->>FLAKE: Evaluate flake
    FLAKE->>FLAKE: Resolve inputs
    FLAKE->>FLAKE: Apply overlays
    FLAKE->>FLAKE: Evaluate host config
    FLAKE->>FLAKE: Evaluate modules
    NIX->>STORE: Build derivations
    STORE-->>NIX: Store paths
    NIX->>SYS: Activate configuration
    SYS-->>U: System updated
```

---

## Summary

This architecture enables:

1. **Unified Configuration**: Single source of truth for all machines
2. **Cross-Platform Support**: Same modules work across NixOS, macOS, and Android
3. **Modular Design**: 60+ independent, composable modules
4. **Type-Safe Options**: All configuration is validated at build time
5. **Reproducible Builds**: Flake lock ensures consistent builds
6. **Secret Management**: SOPS integration with per-host key selection
7. **Easy Extension**: Well-defined patterns for adding hosts and modules
