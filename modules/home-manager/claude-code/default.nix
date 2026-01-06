{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.claude-code;
in
{
  options.modules.claude-code = {
    enable = mkEnableOption "claude-code";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      claude = ''
        env \
          CLAUDE_CODE_USE_VERTEX=1 \
          GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.claude/sa.json \
          GOOGLE_CLOUD_PROJECT=lv-playground-genai \
          CLOUD_ML_REGION=global \
          claude'';

      claude-kanban = ''
        env \
          CLAUDE_CODE_USE_VERTEX=1 \
          GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.claude/sa.json \
          GOOGLE_CLOUD_PROJECT=lv-playground-genai \
          CLOUD_ML_REGION=global \
          ${pkgs.bun}/bin/bunx vibe-kanban'';
    };

    programs.claude-code = {
      enable = cfg.enable;

      # MCP servers configuration
      mcpServers = config.modules.mcp-servers.servers;

      # User-level CLAUDE.md memory file
      memory.source = ./CLAUDE.md;

      # Directory-based configuration (prioritized over inline)
      commandsDir = ./commands;
      agentsDir = ./agents;
      rulesDir = ./rules;
      skillsDir = ./skills;
      hooksDir = ./hooks;

      # Settings (JSON configuration fallback)
      settings = {
        # Model configuration
        model = "claude-opus-4-5@20251101";

        # Session cleanup (default: 30 days)
        cleanupPeriodDays = 30;

        # Output style adjustment
        outputStyle = "Explanatory";

        # Extended thinking enabled by default
        alwaysThinkingEnabled = true;

        # Environment variables applied to every session
        env = {
          DISABLE_AUTOUPDATER = "1";
          DISABLE_TELEMETRY = "1";
          DISABLE_ERROR_REPORTING = "1";
        };

        # Permission settings
        # Pre-allow common safe commands to avoid unnecessary prompts
        # (Boris's tip #10: use /permissions to pre-allow safe commands)
        permissions = {
          defaultMode = "acceptEdits";
          allow = [
            # Version control
            "Bash(git:*)"
            "Bash(gh:*)"
            # Package managers (read-only operations)
            "Bash(npm list:*)"
            "Bash(npm info:*)"
            "Bash(pnpm list:*)"
            "Bash(yarn list:*)"
            # Build tools
            "Bash(make:*)"
            "Bash(cargo build:*)"
            "Bash(cargo test:*)"
            "Bash(cargo check:*)"
            "Bash(cargo clippy:*)"
            "Bash(go build:*)"
            "Bash(go test:*)"
            # Nix ecosystem
            "Bash(nix:*)"
            "Bash(nixfmt:*)"
            "Bash(statix:*)"
            "Bash(home-manager:*)"
            "Bash(darwin-rebuild:*)"
            # Linters and formatters
            "Bash(eslint:*)"
            "Bash(prettier:*)"
            "Bash(shfmt:*)"
            # Python ecosystem (uv + ruff)
            "Bash(python:*)"
            "Bash(python3:*)"
            "Bash(uv:*)"
            "Bash(ruff:*)"
            "Bash(pytest:*)"
            # Common utilities
            "Bash(jq:*)"
            "Bash(yq:*)"
            "Bash(wc:*)"
            "Bash(sort:*)"
            "Bash(uniq:*)"
            "Bash(diff:*)"
            "Bash(which:*)"
            "Bash(type:*)"
          ];
          ask = [
            "Bash(rm:*)"
            "Bash(sudo:*)"
            "Bash(npm install:*)"
            "Bash(npm run:*)"
            "Bash(pnpm install:*)"
            "Bash(yarn install:*)"
            # Python package installation (modifies environment)
            "Bash(uv add:*)"
            "Bash(uv remove:*)"
            "Bash(uv sync:*)"
          ];
          deny = [
            "Read(./.env)"
            "Read(./.env.*)"
            "Read(./secrets/**)"
            "Bash(curl:*)"
          ];
        };

        # Attribution disabled
        attribution = {
          commit = "";
          pr = "";
        };

        # MCP server settings
        enableAllProjectMcpServers = true;
      };
    };
  };
}
