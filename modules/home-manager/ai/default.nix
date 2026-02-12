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
    ./cursor
    ./gemini-cli
    ./mcp
    ./opencode
    ./skills
  ];

  options.modules.ai = {
    enable = mkEnableOption "AI tools (claude-code, cursor, gemini-cli, opencode, mcp)";

    claude-code = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable claude-code when ai.enable is true";
    };

    cursor = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable cursor when ai.enable is true";
    };

    gemini-cli = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable gemini-cli when ai.enable is true";
    };

    opencode = {
      enable = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = "Enable opencode when ai.enable is true";
      };
      web.enable = mkEnableOption "opencode web UI";
    };

    mcp = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable mcp servers when ai.enable is true";
    };

    skills = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable declarative agent skills when ai.enable is true";
    };
  };

  config = {
    modules = {
      claude-code.enable = mkDefault cfg.claude-code;
      cursor.enable = mkDefault cfg.cursor;
      gemini-cli.enable = mkDefault cfg.gemini-cli;
      opencode = {
        enable = mkDefault cfg.opencode.enable;
        web.enable = mkDefault cfg.opencode.web.enable;
      };
      agent-browser.enable = mkDefault cfg.mcp;
      skills.enable = mkDefault cfg.skills;
    };
  };
}
