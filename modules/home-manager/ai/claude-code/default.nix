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
    sops.secrets."apiKeys/supermemory" = { };

    home.shellAliases = {
      cc = "CLAUDE_CONFIG_DIR=$HOME/.claude-idjo claude";
      cci = "CLAUDE_CONFIG_DIR=$HOME/.claude-idjo claude";
      ccp = "CLAUDE_CONFIG_DIR=$HOME/.claude-paulsjob claude";
    };

    programs.claude-code = {
      enable = cfg.enable;

      context = ./CLAUDE.md;

      package = claudeWrapper;

      enableMcpIntegration = true;

      marketplaces = {
        claude-plugins-official = inputs.claude-plugins-official;
        openai-codex = inputs.openai-codex;
        stitch-skills = inputs.stitch-skills;
      };

      settings = {
        cleanupPeriodDays = 90;
        outputStyle = "Explanatory";
        model = "opus";
        effortLevel = "high";
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
          "claude-supermemory@supermemory-plugins" = true;
          "superpowers@claude-plugins-official" = true;
          "codex@openai-codex" = true;
          "stitch-design@stitch-skills" = true;
          "stitch-build@stitch-skills" = true;
          "stitch-utilities@stitch-skills" = true;
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
