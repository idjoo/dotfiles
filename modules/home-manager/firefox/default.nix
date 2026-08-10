{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.firefox;
in
{
  options.modules.firefox = {
    enable = mkEnableOption "firefox";
  };
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = cfg.enable;
    };
  };
}
