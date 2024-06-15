{ lib
, config
, outputs
, ...
}:
with lib; let
  cfg = config.modules.nh;
in
{
  options.modules.nh = { enable = mkEnableOption "nh"; };
  config =
    mkIf cfg.enable {
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 5";
        flake = "/home/${outputs.username}/dotfiles";
      };
    };
}
