{
  lib,
  config,
  inputs,
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
  };
}
