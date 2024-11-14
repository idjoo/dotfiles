{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.ssh;

  rofi-askpass = pkgs.writers.writeBashBin "rofi-askpass" ''
    ${pkgs.rofi}/bin/rofi -dmenu -password -i -no-fixed-num-lines -p "password: "
  '';
in
{
  options.modules.ssh = {
    enable = mkEnableOption "ssh";
  };
  config = mkIf cfg.enable {
    services = {
      openssh.enable = true;
    };

    programs.ssh = {
      askPassword = "${rofi-askpass}/bin/rofi-askpass";
    };
  };
}
