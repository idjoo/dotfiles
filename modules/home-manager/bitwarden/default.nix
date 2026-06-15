{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.bitwarden;
in
{
  options.modules.bitwarden = {
    enable = mkEnableOption "bitwarden";
    email = mkOption {
      type = types.str;
      default = "vian@paulsjob.ai";
      description = "The email address for your bitwarden account.";
    };
  };
  config = mkIf cfg.enable {
    programs.rbw = {
      enable = cfg.enable;
      settings = {
        email = cfg.email;
        base_url = "https://vault.idjo.cc/";
        lock_timeout = 300;
        pinentry = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-rofi;
      };
    };
  };
}
