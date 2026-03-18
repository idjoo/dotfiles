{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.claude-code;

  claudeWrapper = pkgs.writeShellScriptBin "claude" ''
    export ANTHROPIC_AUTH_TOKEN=$(cat ${config.sops.secrets."apiKeys/byteplus".path})
    export SUPERMEMORY_CC_API_KEY=$(cat ${config.sops.secrets."apiKeys/supermemory".path})
    exec ${pkgs.llm-agents.claude-code}/bin/claude "$@"
  '';
in
{
  options.modules.claude-code = {
    enable = mkEnableOption "claude-code";
  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = mkIf cfg.enable {
    sops.secrets."apiKeys/byteplus" = { };
    sops.secrets."apiKeys/supermemory" = { };

    home.shellAliases = {
      cc = "claude";
    };

    programs.claude-code = {
      enable = cfg.enable;

      memory.source = ./CLAUDE.md;

      package = claudeWrapper;

      enableMcpIntegration = true;

      settings = {
        cleanupPeriodDays = 90;
        outputStyle = "Explanatory";
        alwaysThinkingEnabled = true;
        autoMemoryDirectory = "~/.claude/memory";
        includeGitInstructions = false;

        env = {
          DISABLE_AUTOUPDATER = "1";
          DISABLE_TELEMETRY = "1";
          DISABLE_ERROR_REPORTING = "1";
          ENABLE_TOOL_SEARCH = "0";
          ANTHROPIC_BASE_URL = "https://ark.ap-southeast.bytepluses.com/api/coding";
          ANTHROPIC_MODEL = "kimi-k2.5";
        };

        permissions = {
          defaultMode = "bypassPermissions";
        };

        attribution = {
          commit = "";
          pr = "";
        };

        enableAllProjectMcpServers = true;

        statusLine = {
          type = "command";
          command = "${pkgs.llm-agents.ccstatusline}/bin/ccstatusline";
        };

        enabledPlugins = {
          "claude-supermemory@supermemory-plugins" = true;
        };

        hooks =
          let
            notify = import ./hooks/notify.nix { inherit pkgs; };
          in
          {
            Notification = [
              {
                matcher = "";
                hooks = [ notify ];
              }
            ];

            Stop = [
              {
                hooks = [ notify ];
              }
            ];
          };
      };
    };
  };
}
