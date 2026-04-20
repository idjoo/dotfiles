{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.codex;
in
{
  options.modules.codex = {
    enable = mkEnableOption "codex";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      co = "codex";
    };

    programs.codex = {
      enable = true;

      package = pkgs.llm-agents.codex;

      enableMcpIntegration = true;

      "custom-instructions" = builtins.readFile ./AGENTS.md;

      settings = {
        model = "gpt-5.3-codex";
        model_reasoning_effort = "medium";
        model_provider = "openai";
        model_providers = {
          azure_cognitive_service = {
            name = "Azure Cognitive Service";
            base_url = "https://pauls-mji03ow6-eastus2.cognitiveservices.azure.com/openai/v1";
            env_key = "AZURE_OPENAI_API_KEY";
            wire_api = "responses";
          };
        };

        approval_policy = "never";
        sandbox_mode = "danger-full-access";

        feedback = {
          enabled = false;
        };

        personality = "pragmatic";

        check_for_update_on_startup = false;

        commit_attribution = "";

        features = {
          undo = true;
        };

        hide_agent_reasoning = false;

        model_reasoning_summary = "auto";
      };
    };
  };
}
