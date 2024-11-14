{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.dunst;
in
{
  options.modules.dunst = {
    enable = mkEnableOption "dunst";
  };
  config = mkIf cfg.enable {
    services.dunst = {
      enable = cfg.enable;

      settings = {
        global = {
          origin = "top-right";
        };

        urgency_normal = {
          timeout = 5;
        };
      };
    };
  };
}
