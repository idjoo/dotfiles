{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.dunst;
in
{
  options.modules.dunst = { enable = mkEnableOption "dunst"; };
  config =
    mkIf cfg.enable {
      services.dunst = {
        enable = true;
        settings = {
          global = {
            origin = "top-right";
          };

          urgency_normal = {
            timeout = 10;
          };
        };
      };
    };
}
