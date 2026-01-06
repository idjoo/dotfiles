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
          ${pkgs.claude-code}/bin/claude
      '';
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
        permissions = {
          defaultMode = "acceptEdits";
          allow = [
            "Bash(git:*)"
          ];
          ask = [
            "Bash(rm:*)"
            "Bash(sudo:*)"
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

        # Sandbox settings
        sandbox = {
          enabled = false;
          autoAllowBashIfSandboxed = true;
          excludedCommands = [ "git" "nix" "docker" ];
          network = {
            allowLocalBinding = true;
          };
        };

        # MCP server settings
        enableAllProjectMcpServers = false;
      };
    };
  };
}
