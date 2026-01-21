{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.utils;
in
{
  options.modules.utils = {
    enable = mkEnableOption "utils";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # nix helper for darwin rebuilds
      nh

      # dev environments
      devbox
    ];
  };
}
