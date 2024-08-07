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

        # others
        ripgrep
        fd
        jq
        p7zip

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
      ];
    };
}
