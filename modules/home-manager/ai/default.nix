{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.ai;
in
{

  options.modules.ai = {
    enable = mkEnableOption "AI tools (claude-code, codex, antigravity-cli, opencode, mcp)";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.claude-code
      pkgs.llm-agents.codex
      pkgs.llm-agents.opencode
      pkgs.llm-agents.skills
      pkgs.llm-agents.rtk
    ];

    home.shellAliases = {
      co = "codex";
      cci = "CLAUDE_CONFIG_DIR=$HOME/.claude-idjo claude";
      ccp = "CLAUDE_CONFIG_DIR=$HOME/.claude-paulsjob claude";
    };
  };
}
