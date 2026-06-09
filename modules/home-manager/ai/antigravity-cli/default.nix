{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.antigravity-cli;
in
{
  options.modules.antigravity-cli = {
    enable = mkEnableOption "antigravity-cli";
  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = mkIf cfg.enable {
    home.sessionVariables = {
      GOOGLE_APPLICATION_CREDENTIALS = config.sops.secrets."serviceAccounts/ai".path;
      GOOGLE_CLOUD_PROJECT = "lv-playground-genai";
      GOOGLE_CLOUD_LOCATION = "global";
    };

    programs.antigravity-cli = {
      enable = cfg.enable;

      enableMcpIntegration = true;
      context = {
        AGENTS = ./AGENTS.md;
      };

      settings = {
      };
    };
  };
}
