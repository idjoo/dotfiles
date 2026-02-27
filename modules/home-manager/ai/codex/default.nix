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
        model_provider = "openai";
      };
    };
  };
}
