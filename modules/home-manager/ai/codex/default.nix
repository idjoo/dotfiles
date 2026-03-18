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
      cdx = "codex";
    };

    programs.codex = {
      enable = true;

      package = pkgs.llm-agents.codex;

      enableMcpIntegration = true;

      "custom-instructions" = builtins.readFile ./AGENTS.md;

      settings = {
        model = "gpt-5.3-codex";
        model_reasoning_effort = "high";
        model_provider = "openai";

        approval_policy = "never";
        sandbox_mode = "danger-full-access";

        feedback = {
          enabled = false;
        };
      };
    };
  };
}
