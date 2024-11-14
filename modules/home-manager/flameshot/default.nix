{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.flameshot;
in
{
  options.modules.flameshot = {
    enable = mkEnableOption "flameshot";
  };
  config = mkIf cfg.enable {
    services.flameshot = {
      enable = cfg.enable;
    };
  };
}
