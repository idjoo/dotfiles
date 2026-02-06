{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.cursor-agent;
in
{
  options.modules.cursor-agent = {
    enable = mkEnableOption "cursor-agent";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      ca = "${pkgs.cursor-cli}/bin/cursor-agent";
    };

    programs.cursor-agent = {
      enable = cfg.enable;

      package = pkgs.llm-agents.cursor-agent;

      enableMcpIntegration = true;

      settings = {
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
  };
}
