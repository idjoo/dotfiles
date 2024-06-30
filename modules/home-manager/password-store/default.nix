{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.password-store;
in
{
  options.modules.password-store = { enable = mkEnableOption "password-store"; };
  config = mkIf cfg.enable {
    programs.password-store = {
      enable = cfg.enable;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
      };
    };
  };
}
