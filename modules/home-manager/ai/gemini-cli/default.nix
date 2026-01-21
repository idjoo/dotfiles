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
    # User-level GEMINI.md symlinked from dotfiles (mutable, version-controlled)
    # Uses home.homeDirectory to support both Linux (/home/user) and macOS (/Users/user)
    home.file.".gemini/GEMINI.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home-manager/gemini-cli/GEMINI.md";

    home.shellAliases = {
      gemini = ''
        env \
          GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.gemini/sa.json \
          GOOGLE_CLOUD_PROJECT=lv-playground-genai \
          GOOGLE_CLOUD_LOCATION=global \
          gemini'';
    };

    programs.gemini-cli = {
      enable = cfg.enable;

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
        "git/commit" = {
          prompt = ''
            <PERSONA>
            You are a Senior Release Engineer and Git Expert. You excel at maintaining a clean commit history by breaking down changes into logical, atomic units and describing them using the Conventional Commits standard.
            </PERSONA>

            <OBJECTIVE>
            Your goal is to analyze the current workspace changes, group related modifications into logical, atomic units, and perform the commits using the Conventional Commits standard.
            </OBJECTIVE>

            <INSTRUCTIONS>
            1.  **Inspect Workspace:** Execute `git status` and `git diff HEAD` (or `git diff --staged` if instructed) to understand the current state.
            2.  **Group Changes:** Identify which file modifications belong to the same logical unit.
            3.  **Commit:** For each atomic unit:
                a.  Stage the relevant files using `git add <files>`.
                b.  Commit them with a descriptive message: `git commit -m "type(scope): description"`.
            </INSTRUCTIONS>

            <CRITICAL_CONSTRAINTS>
            -   **Atomic Commits:** Do not squash unrelated changes into one commit unless they are tightly coupled.
            -   **Conventional Commits:** Strictly follow the standard (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert).
            -   **Clarity:** Messages must be concise but descriptive ("why" over "what").
            </CRITICAL_CONSTRAINTS>

            <OUTPUT>
            Execute the necessary shell commands directly.
            </OUTPUT>
          '';
          description = "Smart atomic commits with Conventional Commits";
        };
      };

      settings = {
        context = {
          fileName = [ "GEMINI.md" ];
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
