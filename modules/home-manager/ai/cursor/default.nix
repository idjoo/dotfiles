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
              "Shell(git:*)"
              "Shell(gh:*)"
              "Shell(nix:*)"
              "Shell(nh:*)"
              "Shell(uv:*)"
              "Shell(jq:*)"
              "Shell(yq:*)"
              "Shell(rg:*)"
              "Shell(fd:*)"
              "Shell(cat:*)"
              "Shell(eza:*)"
              "Shell(wc:*)"
              "Shell(sort:*)"
              "Shell(uniq:*)"
              "Shell(diff:*)"
              "Shell(which:*)"
              "Shell(type:*)"
              "Shell(readlink:*)"
            ];
            deny = [
              "Read(.env*)"
              "Read(./secrets/**)"
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

          Before doing any tasks always use all available skills you have

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

          ## Context7

          Before doing any tasks always use context7 mcp

          ## Task Tracking

          Use `br` for task tracking
        '';
      };
    };
  };
}
