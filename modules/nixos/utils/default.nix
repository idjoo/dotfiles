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
      monero-gui
      remmina
      telegram-desktop

      # others
      bazel
      bottles
      fd
      git-filter-repo
      gpclient
      jq
      kubectl
      openconnect
      openssl
      p7zip
      rclone
      ripgrep
      sqlite
      zathura

      # custom
      android-unpinner
      httpgenerator
    ];
  };
}
