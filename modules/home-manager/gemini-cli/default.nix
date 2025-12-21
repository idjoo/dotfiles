{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.gemini-cli;
in
{
  options.modules.gemini-cli = {
    enable = mkEnableOption "gemini-cli";
  };

  config = mkIf cfg.enable {
    programs.gemini-cli = {
      enable = cfg.enable;

      defaultModel = "gemini-3-pro-preview";

      context = {
        AGENTS = ./AGENTS.md;
      };

      commands = {
        "git/commit" = {
          prompt = ''
            Analyze workspace changes. Group related modifications into logical, atomic units.
            Commit each unit separately using the Conventional Commits standard, ensuring high-quality, descriptive messages.
          '';
          description = "Smart atomic commits with Conventional Commits";
        };
      };

      settings = {
        context = {
          fileName = [ "AGENTS.md" ];
        };

        general = {
          previewFeatures = true;
          preferredEditor = "neovim";
          vimMode = true;
          disableAutoUpdate = true;
          disableUpdateNag = true;
          checkpointing = {
            enabled = true;
          };
          enablePromptCompletion = true;
          retryFetchErrors = false;
          debugKeystrokeLogging = false;
          sessionRetention = {
            enabled = true;
            maxAge = "30d";
            maxCount = 88;
            minRetention = "1d";
          };
        };
        output = {
          format = "text";
        };
        ui = {
          customThemes = { };
          hideWindowTitle = false;
          showStatusInTitle = true;
          hideTips = true;
          hideBanner = true;
          hideContextSummary = false;
          footer = {
            hideCWD = false;
            hideSandboxStatus = true;
            hideModelInfo = false;
            hideContextPercentage = false;
          };
          hideFooter = false;
          showMemoryUsage = false;
          showLineNumbers = true;
          showCitations = true;
          showModelInfoInChat = false;
          useFullWidth = true;
          useAlternateBuffer = false;
          incrementalRendering = true;
          customWittyPhrases = [
            "Nanem Peju"
            "Ngulum Kontol"
            "Nyepongin Kontol"
            "Jilatin Memek"
          ];
          accessibility = {
            disableLoadingPhrases = false;
            screenReader = false;
          };
        };
        privacy = {
          usageStatisticsEnabled = true;
        };
        model = {
          name = "gemini-3-pro-preview";
        };
        mcpServers = config.modules.mcp-servers.servers;
        security = {
          auth = {
            selectedType = "vertex-ai";
          };
        };
        context = {
          loadMemoryFromIncludeDirectories = true;
        };
        tools = {
          shell = {
            showColor = true;
          };
          useRipgrep = true;
          autoAccept = true;

          allowed = [
            "run_shell_command(ls)"
            "run_shell_command(git)"
          ];
        };
        experimental = {
          enableAgents = true;
        };
      };
    };
  };
}
