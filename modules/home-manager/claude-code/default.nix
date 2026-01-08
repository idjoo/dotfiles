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
    home.packages = [ pkgs.htmldoc ];

    # User-level CLAUDE.md symlinked from dotfiles (mutable, version-controlled)
    # Uses home.homeDirectory to support both Linux (/home/user) and macOS (/Users/user)
    home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/modules/home-manager/claude-code/CLAUDE.md";

    home.shellAliases = {
      claude = ''
        env \
          CLAUDE_CODE_USE_VERTEX=1 \
          ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-5@20251101 \
          ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-5@20250929 \
          ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5@20251001 \
          GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.claude/sa.json \
          GOOGLE_CLOUD_PROJECT=lv-playground-genai \
          CLOUD_ML_REGION=global \
          claude'';

      claude-kanban = ''
        env \
          CLAUDE_CODE_USE_VERTEX=1 \
          ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-5@20251101 \
          ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-5@20250929 \
          ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5@20251001 \
          GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.claude/sa.json \
          GOOGLE_CLOUD_PROJECT=lv-playground-genai \
          CLOUD_ML_REGION=global \
          ${pkgs.bun}/bin/bunx vibe-kanban'';
    };

    programs.claude-code = {
      enable = cfg.enable;

      # MCP servers configuration
      mcpServers = config.modules.mcp-servers.servers;

      commandsDir = ./commands;

      # Settings
      settings = {
        # Model configuration
        model = "opus";

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
        permissions = {
          defaultMode = "acceptEdits";
          allow = [
            # Version control
            "Bash(git:*)"
            "Bash(gh:*)"
            # Package managers (read-only operations)
            "Bash(pnpm list:*)"
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
            "Bash(nh:*)"
            # Python ecosystem (uv + ruff)
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
            "Bash(bq query:*)"
            # Modern CLI tools (eza, fd, rg replace ls, find, grep)
            "Bash(eza:*)"
            "Bash(fd:*)"
            "Bash(rg:*)"
            "Bash(cat:*)"
            "Bash(tmux:*)"
          ];
          ask = [
            "Bash(rm:*)"
            "Bash(sudo:*)"
            "Bash(pnpm install:*)"
            # Python package installation (modifies environment)
            "Bash(uv add:*)"
            "Bash(uv remove:*)"
            "Bash(uv sync:*)"
          ];
          deny = [
            "Read(./.env)"
            "Read(./.env.*)"
            "Read(./secrets/**)"
          ];
        };

        # Attribution disabled
        attribution = {
          commit = "";
          pr = "";
        };

        # MCP server settings
        enableAllProjectMcpServers = true;

        # Plugins
        enabledPlugins = {
          "context-management@claude-code-workflows" = true;
          "python-development@claude-code-workflows" = true;
          "javascript-typescript@claude-code-workflows" = true;
          "backend-development@claude-code-workflows" = true;
          "full-stack-orchestration@claude-code-workflows" = true;
          "cloud-infrastructure@claude-code-workflows" = true;
        };

        # Status line - CCometixLine
        statusLine = {
          type = "command";
          command = "~/.claude/ccline/ccline";
          padding = 0;
        };

        # Hooks
        hooks = {
          Notification = [
            {
              matcher = "";
              hooks = [ (import ./hooks/notify.nix { inherit pkgs; }) ];
            }
          ];
          Stop = [
            {
              hooks = [ (import ./hooks/notify.nix { inherit pkgs; }) ];
            }
          ];
        };
      };
    };
  };
}
