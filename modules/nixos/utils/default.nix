{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.utils;
in
{
  options.modules.utils = { enable = mkEnableOption "utils"; };
  config =
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        # archive
        zip
        unzip

        # clipboard
        xsel
        xclip

        # nix
        nurl
        nix-index
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

        # custom
        android-unpinner
        httpgenerator
      ];
    };
}
