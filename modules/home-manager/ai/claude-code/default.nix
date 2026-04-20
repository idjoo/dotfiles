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
