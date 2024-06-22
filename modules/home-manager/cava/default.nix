{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.cava;
in
{
  options.modules.cava = { enable = mkEnableOption "cava"; };
  config =
    mkIf cfg.enable {
      programs.cava = {
        enable = true;
        settings = {
          general = {
            framerate = 60;
          };
        };
      };
    };
}
