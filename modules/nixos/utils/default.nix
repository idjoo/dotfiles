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
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      zlib
      gcc
      glibc
    ];

    services.xrdp.enable = true;
    services.xrdp.audio.enable = true;
    services.xrdp.defaultWindowManager = "${pkgs.herbstluftwm}/bin/herbstluftwm --locked";

    environment.localBinInPath = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };
    services.flatpak.enable = true;

    environment.systemPackages = with pkgs; [
      # archive
      unzip
      zip

      # clipboard
      xclip
      xsel

      # nix
      nix-init
      nix-output-monitor
      nurl

      # desktop app
      dbeaver-bin
      libreoffice-qt6-fresh
      discord

      # others
      bottles
      fd
      git-filter-repo
      jq
      kubectl
      openssl
      p7zip
      rclone
      ripgrep
      sqlite
      zathura
      gh
      oci-cli
      docker-buildx
      code-cursor
      nodejs
      gemini-cli

      # custom
      # android-unpinner
      # httpgenerator
    ];
  };
}
