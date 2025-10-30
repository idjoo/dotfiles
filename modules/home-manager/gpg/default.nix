{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.gpg;
in
{
  options.modules.gpg = {
    enable = mkEnableOption "gpg";
  };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = cfg.enable;
      homedir = "${config.xdg.dataHome}/gnupg";
      mutableKeys = false;
      mutableTrust = false;
      publicKeys = [ ];
      settings = { };
    };

    services.gpg-agent = {
      enable = cfg.enable;
      enableSshSupport = false;
      pinentry = {
        package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-rofi;
      };
    };
  };
}
