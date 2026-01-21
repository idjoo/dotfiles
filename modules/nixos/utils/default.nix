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
    gui.enable = mkEnableOption "Linux GUI utilities";
  };
  config = mkIf cfg.enable {
    # nix-ld for running unpatched binaries
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      zlib
      gcc
      glibc
    ];

    environment.localBinInPath = true;

    environment.systemPackages =
      with pkgs;
      [
        # X11 clipboard
        xclip
        xsel
      ]
      ++ optionals cfg.gui.enable [
        # Linux-only GUI apps
        libreoffice-qt6-fresh
        discord
        bottles
        zathura
      ];
  };
}
