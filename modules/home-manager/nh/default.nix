{
  lib,
  config,
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
      flake = "${config.home.homeDirectory}/dotfiles";

      clean = {
        enable = true;
        extraArgs = "--keep 5 --keep-since 3d";
      };
    };
  };
}
