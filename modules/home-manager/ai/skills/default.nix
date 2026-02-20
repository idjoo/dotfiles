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
        "cursor"
        "gemini-cli"
      ];

      sources = [
        {
          source = "idjoo/skills";
          skills = [ "*" ];
        }
        {
          source = "obra/superpowers";
          skills = [ "*" ];
        }
        {
          source = "wshobson/agents";
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
          source = "waynesutton/convexskills";
          skills = [ "*" ];
        }
        {
          source = "vercel-labs/agent-browser";
          skills = [ "agent-browser" ];
        }
        {
          source = "vercel-labs/agent-browser";
          skills = [ "agent-browser" ];
        }
        {
          source = "softaworks/agent-toolkit";
          skills = [ "qa-test-planner" ];
        }
      ];
    };
  };
}
