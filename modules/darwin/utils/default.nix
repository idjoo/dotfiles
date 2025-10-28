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
    gui.enable = mkEnableOption "utils.gui";
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
        kubectl
        openssl
        p7zip
        ripgrep
        sqlite
        gh
        nodejs
        gemini-cli
        uv
      ]
      ++ (optionals cfg.gui.enable (
        with pkgs;
        [
          # desktop app
          dbeaver-bin
          code-cursor
          zathura
        ]
      ))
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
