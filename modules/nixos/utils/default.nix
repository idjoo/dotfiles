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
      libgcc
    ];

    services.xrdp.enable = true;
    services.xrdp.audio.enable = true;
    services.xrdp.defaultWindowManager = "${pkgs.herbstluftwm}/bin/herbstluftwm --locked";

    environment.localBinInPath = true;

    environment.systemPackages = with pkgs; [
      # archive
      zip
      unzip

      # clipboard
      xsel
      xclip

      # nix
      nurl
      nix-init
      nix-output-monitor

      # desktop app
      telegram-desktop
      monero-gui
      zathura
      dbeaver-bin
      remmina
      rclone

      # others
      ripgrep
      fd
      jq
      p7zip
      kubectl
      sqlite
      openssl
      gpclient
      openconnect

      # custom
      android-unpinner
      httpgenerator
    ];
  };
}
