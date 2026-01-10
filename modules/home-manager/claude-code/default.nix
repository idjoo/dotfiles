{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.claude-code;

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

      mcpServers = config.modules.mcp-servers.servers;

      commandsDir = ./commands;

      settings = {
        model = "opus";
        cleanupPeriodDays = 30;
        outputStyle = "Explanatory";
        alwaysThinkingEnabled = true;

        env = {
          DISABLE_AUTOUPDATER = "1";
          DISABLE_TELEMETRY = "1";
          DISABLE_ERROR_REPORTING = "1";
        };

        permissions = {
          defaultMode = "acceptEdits";
          allow = [
            "Bash(git:*)"
            "Bash(gh:*)"
            "Bash(pnpm list:*)"
            "Bash(make:*)"
            "Bash(cargo build:*)"
            "Bash(cargo test:*)"
            "Bash(cargo check:*)"
            "Bash(cargo clippy:*)"
            "Bash(go build:*)"
            "Bash(go test:*)"
            "Bash(nix:*)"
            "Bash(nixfmt:*)"
            "Bash(nh:*)"
            "Bash(uv:*)"
            "Bash(ruff:*)"
            "Bash(pytest:*)"
            "Bash(jq:*)"
            "Bash(yq:*)"
            "Bash(wc:*)"
            "Bash(sort:*)"
            "Bash(uniq:*)"
            "Bash(diff:*)"
            "Bash(which:*)"
            "Bash(type:*)"
            "Bash(bq query:*)"
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

        attribution = {
          commit = "";
          pr = "";
        };

        enableAllProjectMcpServers = true;

        enabledPlugins = {
          "context-management@claude-code-workflows" = true;
          "python-development@claude-code-workflows" = true;
          "javascript-typescript@claude-code-workflows" = true;
          "backend-development@claude-code-workflows" = true;
          "full-stack-orchestration@claude-code-workflows" = true;
          "cloud-infrastructure@claude-code-workflows" = true;
          "code-documentation@claude-code-workflows" = true;
        };

        statusLine = {
          type = "command";
          command = "~/.claude/ccline/ccline";
          padding = 0;
        };

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
