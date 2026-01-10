{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.claude-code;

  # Wrapper script for claude with Vertex AI configuration
  # Named "claude" and calls original binary by full store path to avoid recursion
  claudeWrapper = pkgs.writeShellScriptBin "claude" ''
    export CLAUDE_CODE_USE_VERTEX=1
    export ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-5@20251101
    export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-5@20250929
    export ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5@20251001
    export GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.claude/sa.json
    export GOOGLE_CLOUD_PROJECT=lv-playground-genai
    export CLOUD_ML_REGION=global
    exec ${pkgs.claude-code}/bin/claude "$@"
  '';

  agents = pkgs.writeShellScriptBin "agents" ''
    set -euo pipefail

    PLUGIN_NAME="''${1%%:*}"
    FULL_ARG="$1"
    PROMPT="''${2:-}"
    SESSION_NAME="claude-agents"
    SETTINGS_FILE=".claude/settings.local.json"

    if ! ${pkgs.tmux}/bin/tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      ${pkgs.tmux}/bin/tmux new-session -d -s "$SESSION_NAME"
    else
      ${pkgs.tmux}/bin/tmux new-window -t "$SESSION_NAME"
    fi

    TARGET="$SESSION_NAME"

    if [[ -f "$SETTINGS_FILE" ]]; then
      ${pkgs.jq}/bin/jq '.enabledPlugins = {}' "$SETTINGS_FILE" >"''${SETTINGS_FILE}.tmp" &&
        mv "''${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
    fi

    CLAUDE_CMD="claude --dangerously-skip-permissions '/$FULL_ARG'"
    [[ -n "$PROMPT" ]] && CLAUDE_CMD="$CLAUDE_CMD '$PROMPT'"

    ${pkgs.tmux}/bin/tmux send-keys -t "$TARGET" "claude plugin install --scope local '$PLUGIN_NAME' && $CLAUDE_CMD" Enter

    echo "Started in tmux session '$SESSION_NAME'"
  '';
in
{
  options.modules.claude-code = {
    enable = mkEnableOption "claude-code";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.htmldoc
      agents
    ];

    # User-level CLAUDE.md symlinked from dotfiles (mutable, version-controlled)
    # Uses home.homeDirectory to support both Linux (/home/user) and macOS (/Users/user)
    home.file.".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home-manager/claude-code/CLAUDE.md";

    home.shellAliases = {
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

      package = claudeWrapper;

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
            "mcp__context7__*"
            "mcp__tmux__*"
            "mcp__playwright__*"
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
          "code-documentation@claude-code-workflows" = true;
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
