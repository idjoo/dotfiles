{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.cursor;
in
{
  imports = [
    inputs.cursor.homeModules.cursor
  ];

  options.modules.cursor = {
    enable = mkEnableOption "cursor";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      ca = "${pkgs.cursor-cli}/bin/cursor-agent";
    };

    programs.cursor = {
      enable = cfg.enable;

      enableMcpIntegration = true;

      cli = {
        enable = true;

        package = pkgs.llm-agents.cursor-agent;

        settings = {
          editor = {
            vimMode = true;
          };
          display = {
            showLineNumbers = true;
            showThinkingBlocks = true;
          };
          permissions = {
            allow = [
              "*"
            ];
          };
          attribution = {
            attributeCommitsToAgent = false;
            attributePRsToAgent = false;
          };
        };
      };

      rules = {
        main = ''
          ---
          description: "Main Agent Instructions"
          alwaysApply: true
          ---

          # Agent Instructions

          ## Skills

          Always use superpower skill

          ## Python

          When running python or pip always use uv:

          ```bash
          uv run script.py
          uv run --with <deps> script.py

          # For inline scripts, use a HEREDOC with EOPY:
          uv run python - << 'EOPY'
          import sys
          print("Inline python script")
          EOPY
          ```

          Use inline python scripts whenever possible so doesnt leave any temporary files scattered

          ## Context7

          Before doing any tasks always use context7 mcp

          ## Task Tracking

          Use `br` for task tracking
        '';
      };
    };
  };
}
