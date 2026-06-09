{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.modules.skills;
in
{
  imports = [
    inputs.skills.homeModules.default
  ];

  options.modules.skills = {
    enable = lib.mkEnableOption "declarative agent skills via skills.sh";
  };

  config = lib.mkIf cfg.enable {
    programs.skills = {
      enable = true;

      mode = "copy";

      defaultAgents = [
        "opencode"
        "claude-code"
        "codex"
      ];

      sources = [
        {
          source = "idjoo/skills";
          skills = [ "*" ];
        }
        {
          source = "anthropics/skills";
          skills = [ "*" ];
        }
        {
          source = "remotion-dev/skills";
          skills = [ "*" ];
        }
        {
          source = "vercel-labs/agent-browser";
          skills = [ "agent-browser" ];
        }
      ];
    };
  };
}
