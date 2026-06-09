{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.antigravity-cli;
in
{
  options.modules.antigravity-cli = {
    enable = mkEnableOption "antigravity-cli";
  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = mkIf cfg.enable {
    programs.antigravity-cli = {
      enable = cfg.enable;
      enableMcpIntegration = true;
      context = {
        AGENTS = ./AGENTS.md;
      };

      commands = {
        "context" = {
          prompt = ''
            <PERSONA>
            You are a Senior Technical Writer's assistant and a Documentation Architect. You specialize in analyzing complex codebases and synthesizing them into clear, high-level architectural summaries optimized for AI consumption.
            </PERSONA>

            <OBJECTIVE>
            Your task is to analyze the provided codebase context and generate a structured summary that explains the ARCHITECTURE, DATA FLOW, and PURPOSE of the code. This summary will be used by other AI agents to understand the system quickly.
            </OBJECTIVE>

            <INSTRUCTIONS>
            1.  **Analyze the Context:** Read the provided file structure, file contents, and logic in the input.
                Context Input:
                ```
                {{args}}
                ```
            2.  **Synthesize Information:** Identify the core purpose, the organization of files, the key classes/functions, and how data moves through the system.
            3.  **Format Output:** detailed in the <OUTPUT> section.
            </INSTRUCTIONS>

            <CRITICAL_CONSTRAINTS>
            -   **No Raw Code:** Do not output code blocks unless necessary for specific config examples.
            -   **High-Level & Accurate:** Balance brevity with technical depth.
            -   **AI-Optimized:** The output must be structured so another AI can parse it easily.
            </CRITICAL_CONSTRAINTS>

            <OUTPUT>
            Generate a Markdown response following this exact structure:

            1.  **Project Overview:** 1-2 sentences on what this module does.
            2.  **File Structure:** Briefly explain the organization of the files provided.
            3.  **Key Components:** List main classes/functions and their responsibilities.
            4.  **Logic Flow:** Explain the data lifecycle (Inputs -> Processing -> Outputs).
            </OUTPUT>
          '';
          description = "Context summarization generator";
        };
      };

      settings = {
        context = {
          fileName = [ "AGENTS.md" ];
          loadMemoryFromIncludeDirectories = true;
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
          showMemoryUsage = true;
          showLineNumbers = true;
          showCitations = true;
          showModelInfoInChat = false;
          customWittyPhrases = [
            "Nanem Peju"
            "Ngulum Kontol"
            "Nyepongin Kontol"
            "Jilatin Memek"
            "Peras Tete"
          ];
          accessibility = {
            disableLoadingPhrases = false;
            screenReader = false;
          };
        };
        privacy = {
          usageStatisticsEnabled = false;
        };
        model = {
          name = "gemini-3-flash-preview";
          compressionThreshold = 0.75;
        };
        mcpServers = config.programs.mcp.servers;
        security = {
          enablePermanentToolApproval = true;
          auth = {
            selectedType = "vertex-ai";
          };
        };
        tools = {
          shell = {
            showColor = true;
          };
          useRipgrep = true;
          autoAccept = true;

          allowed = [
            "run_shell_command(git)"
          ];
          exclude = [
            "save_memory"
          ];
        };

        experimental = {
          enableAgents = true;
          extensionManagement = true;
          extensionReloading = true;
          jitContext = true;
          codebaseInvestigatorSettings.enabled = true;
          introspectionAgentSettings.enabled = true;
          skills = true;
        };
      };
    };
  };
}
