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
    cli.enable = mkEnableOption "CLI utilities";
    nix.enable = mkEnableOption "Nix tooling utilities";
    gui.enable = mkEnableOption "GUI utilities";
    custom.enable = mkEnableOption "Custom packages";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        # archive
        unzip
        zip
        p7zip

        # core cli
        fd
        jq
        ripgrep
        openssl
        sqlite
        rclone
        git-filter-repo
      ]
      ++ optionals cfg.nix.enable [
        # nix tooling
        nix-init
        nix-output-monitor
        nurl
      ]
      ++ optionals cfg.cli.enable [
        # node
        bun
        pnpm
        nodejs

        # python
        uv

        # git
        gh

        # kubernetes
        kubectl
        skaffold

        # cloud/devops
        oci-cli
        docker-buildx
      ]
      ++ optionals cfg.gui.enable [
        # IDE
        code-cursor

        # database
        dbeaver-bin
      ]
      ++ optionals cfg.custom.enable [
        # custom packages
        android-unpinner
        httpgenerator
      ];
  };
}
