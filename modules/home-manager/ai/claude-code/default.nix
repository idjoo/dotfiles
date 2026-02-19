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
      cc = "claude";
    };

    home.file.".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home-manager/claude-code/CLAUDE.md";

    programs.claude-code = {
      enable = cfg.enable;

      package = pkgs.llm-agents.claude-code;

      enableMcpIntegration = true;

      settings = {
        model = "opus";
        cleanupPeriodDays = 30;
        outputStyle = "Explanatory";
        alwaysThinkingEnabled = true;

        env = {
          DISABLE_AUTOUPDATER = "1";
          DISABLE_TELEMETRY = "1";
          DISABLE_ERROR_REPORTING = "1";
          SUPERMEMORY_CC_API_KEY = "***REDACTED***";
          ENABLE_TOOL_SEARCH = "0";
          CLAUDE_CODE_USE_VERTEX = "1";
          ANTHROPIC_DEFAULT_OPUS_MODEL = "claude-opus-4-6@default";
          ANTHROPIC_DEFAULT_SONNET_MODEL = "claude-sonnet-4-5@20250929";
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "claude-haiku-4-5@20251001";
          GOOGLE_APPLICATION_CREDENTIALS = config.sops.secrets."serviceAccounts/ai".path;
          GOOGLE_CLOUD_PROJECT = "lv-playground-genai";
          CLOUD_ML_REGION = "global";
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

        # enabledPlugins = {
        #   "claude-supermemory@supermemory-plugins" = true;
        # };

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

            # Memory
            # SessionStart = [
            #   {
            #     matcher = "startup|resume";
            #     hooks = [
            #       {
            #         type = "command";
            #         command = "${pkgs.bun}/bin/bunx github:idjoo/memory-ts hooks session-start --claude";
            #         timeout = 10;
            #       }
            #     ];
            #   }
            # ];
            #
            # UserPromptSubmit = [
            #   {
            #     hooks = [
            #       {
            #         type = "command";
            #         command = "${pkgs.bun}/bin/bunx github:idjoo/memory-ts hooks user-prompt --claude";
            #         timeout = 10;
            #       }
            #     ];
            #   }
            # ];
            #
            # PreCompact = [
            #   {
            #     matcher = "auto|manual";
            #     hooks = [
            #       {
            #         type = "command";
            #         command = "${pkgs.bun}/bin/bunx github:idjoo/memory-ts hooks curation --claude";
            #         timeout = 10;
            #       }
            #     ];
            #   }
            # ];
            #
            # SessionEnd = [
            #   {
            #     matcher = "auto|manual";
            #     hooks = [
            #       {
            #         type = "command";
            #         command = "${pkgs.bun}/bin/bunx github:idjoo/memory-ts hooks curation --claude";
            #         timeout = 10;
            #       }
            #     ];
            #   }
            # ];

          };
      };
    };
  };
}
