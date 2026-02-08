{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.password-store;
  passDir = "${config.xdg.dataHome}/pass";
in
{
  options.modules.password-store = {
    enable = mkEnableOption "password-store";
  };
  config = mkIf cfg.enable {
    programs.password-store = {
      enable = cfg.enable;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_DIR = passDir;
      };
    };

    home.activation.clonePasswordStore = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if [ ! -d "${passDir}/.git" ]; then
        export PATH="${pkgs.openssh}/bin:$PATH"
        run ${pkgs.git}/bin/git clone git@github.com:idjoo/pass.git "${passDir}"
      fi
    '';
  };
}
