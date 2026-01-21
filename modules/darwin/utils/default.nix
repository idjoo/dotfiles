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
    custom.enable = mkEnableOption "utils.custom";
  };
  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        # archive
        unzip
        zip

        # nix
        nix-init
        nix-output-monitor
        nurl

        # others
        fd
        jq
        git-filter-repo
        openssl
        p7zip
        ripgrep
        sqlite
        devbox
        nh
      ]
      ++ (optionals cfg.custom.enable (
        with pkgs;
        [
          # custom
          android-unpinner
          httpgenerator
        ]
      ));
  };
}
