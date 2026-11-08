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
    enable = mkEnableOption "AI tools (claude-code, codex, t3code, antigravity-cli, opencode, mcp)";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.claude-code
      pkgs.llm-agents.codex
      pkgs.llm-agents.t3code
      pkgs.llm-agents.antigravity-cli
      pkgs.llm-agents.opencode
      pkgs.llm-agents.skills
    ];

    home.shellAliases = {
      co = "codex";
      cci = "CLAUDE_CONFIG_DIR=$HOME/.claude-idjo claude";
      ccp = "CLAUDE_CONFIG_DIR=$HOME/.claude-paulsjob claude";
      ccpj = "CLAUDE_CONFIG_DIR=$HOME/.claude-pj claude";
    };

    home.file = builtins.listToAttrs (map (name: {
      name = ".claude-pj/${name}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/${name}";
    }) [
      "CLAUDE.md"
      "plugins"
      "skills"
    ]);

    # Claude writes settings atomically next to the symlink target. A direct
    # link avoids making it create temporary files in the read-only Nix store.
    home.activation.claudePjSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      settings=${lib.escapeShellArg "${config.home.homeDirectory}/.claude-pj/settings.json"}
      if [ ! -e "$settings" ] && [ ! -L "$settings" ]; then
        run mkdir -p "$(dirname "$settings")"
        run ln -s ${lib.escapeShellArg "${config.home.homeDirectory}/.claude/settings.json"} "$settings"
      fi
    '';
  };
}
