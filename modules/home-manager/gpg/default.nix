{
  pkgs,
  lib,
  config,
  hostName,
  ...
}:
with lib;
let
  cfg = config.modules.gpg;

  identity =
    {
      ox = "idjo";
      horse = "devoteam";
      snake = "devoteam";
      dragon = "idjo";
      tiger = "idjo";
      monkey = "idjo";
    }
    ."${hostName}";
in
{
  options.modules.gpg = {
    enable = mkEnableOption "gpg";
  };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = cfg.enable;
      homedir = "${config.xdg.dataHome}/gnupg";
      mutableKeys = true;
      mutableTrust = true;
      settings = { };
    };

    services.gpg-agent = {
      enable = cfg.enable;
      enableSshSupport = false;
      pinentry = {
        package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-rofi;
      };
    };

    home.activation.importGpgKeys = lib.hm.dag.entryAfter [ "sops-nix" ] ''
      export GNUPGHOME="${config.xdg.dataHome}/gnupg"
      run ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets."gpgKeys/${identity}/public".path} || true
      run ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets."gpgKeys/${identity}/private".path} || true
    '';
  };
}
