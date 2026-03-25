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
      env = {
        GOPATH = ".local/share/go";
        GOBIN = ".local/share/go/bin";
      };
    };
  };
}
