{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.zen-browser;
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  options.modules.zen-browser = {
    enable = mkEnableOption "zen-browser";
  };

  config = mkIf cfg.enable {
    programs.zen-browser = {
      enable = cfg.enable;
    };

    stylix.targets.zen-browser.enable = false;
  };
}
