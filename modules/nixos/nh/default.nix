{
  lib,
  config,
  outputs,
  ...
}:
with lib;
let
  cfg = config.modules.nh;
in
{
  options.modules.nh = {
    enable = mkEnableOption "nh";
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;

      clean = {
        enable = true;
        extraArgs = "--keep-since 30d --keep 10";
      };
    };
  };
}
