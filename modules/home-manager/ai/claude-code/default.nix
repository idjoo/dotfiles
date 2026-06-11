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
    home.shellAliases = {
      cc = "ANTHROPIC_BASE_URL=https://headroom-621964697798.europe-west10.run.app CLAUDE_CONFIG_DIR=$HOME/.claude-idjo claude";
      cci = "ANTHROPIC_BASE_URL=https://headroom-621964697798.europe-west10.run.app CLAUDE_CONFIG_DIR=$HOME/.claude-idjo claude";
      ccp = "ANTHROPIC_BASE_URL=https://headroom-621964697798.europe-west10.run.app CLAUDE_CONFIG_DIR=$HOME/.claude-paulsjob claude";
    };

    programs.claude-code = {
      enable = cfg.enable;

      context = ./CLAUDE.md;

      package = claudeWrapper;

      enableMcpIntegration = true;

      marketplaces = {
        claude-plugins-official = inputs.claude-plugins-official;
        openai-codex = inputs.openai-codex;
      };

      settings = {
        cleanupPeriodDays = 90;
        outputStyle = "Explanatory";
        model = "opus";
        effortLevel = "xhigh";
        includeGitInstructions = false;
        enableAllProjectMcpServers = true;
        language = "english";
        voiceEnabled = true;
        teammateMode = "auto";

        env = {
          DISABLE_AUTOUPDATER = "1";
          DISABLE_TELEMETRY = "1";
          DISABLE_ERROR_REPORTING = "1";
          ENABLE_TOOL_SEARCH = "0";
          CLAUDE_CODE_DISABLE_1M_CONTEXT = "1";
        };

        permissions = {
          defaultMode = "bypassPermissions";
        };

        attribution = {
          commit = "";
          pr = "";
        };

        statusLine = {
          type = "command";
          command = "${pkgs.llm-agents.ccstatusline}/bin/ccstatusline";
        };

        enabledPlugins = {
          "superpowers@claude-plugins-official" = true;
          "codex@openai-codex" = true;
        };

        spinnerVerbs = {
          mode = "replace";
          verbs = [
            "Nanem Peju"
            "Ngulum Kontol"
            "Nyepongin Kontol"
            "Jilatin Memek"
            "Ngemut Pentil"
            "Grepe Tete"
          ];
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
