{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.go;
in
{
  options.modules.go = {
    enable = mkEnableOption "go";
  };
  config = mkIf cfg.enable {
    programs.go = {
      enable = cfg.enable;
      goPath = ".local/share/go";
      goBin = ".local/share/go/bin";
      packages = { };
    };
  };
}
