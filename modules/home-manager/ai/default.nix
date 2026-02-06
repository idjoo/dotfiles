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
  imports = [
    ./claude-code
    ./gemini-cli
    ./mcp
    ./opencode
  ];

  options.modules.ai = {
    enable = mkEnableOption "AI tools (claude-code, gemini-cli, opencode, mcp)";

    claude-code = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable claude-code when ai.enable is true";
    };

    gemini-cli = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable gemini-cli when ai.enable is true";
    };

    opencode = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable opencode when ai.enable is true";
    };

    mcp = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable mcp servers when ai.enable is true";
    };
  };

  config = {
    modules = {
      claude-code.enable = mkDefault cfg.claude-code;
      gemini-cli.enable = mkDefault cfg.gemini-cli;
      opencode.enable = mkDefault cfg.opencode;
      agent-browser.enable = mkDefault cfg.mcp;
    };

    home.packages = [
      pkgs.cursor-cli
    ];

    home.shellAliases = {
      ca = "${pkgs.cursor-cli}/bin/cursor-agent";
    };
  };
}
