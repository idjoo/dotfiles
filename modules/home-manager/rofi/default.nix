{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.rofi;
in
{
  options.modules.rofi = { enable = mkEnableOption "rofi"; };
  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      location = "center";

      terminal = "${pkgs.wezterm}/bin/wezterm";

      extraConfig = {
        modi = "drun,run,ssh";
        show-icon = true;
      };

      plugins = with pkgs; [
        rofi-calc
        rofi-emoji
        rofi-bluetooth
        rofi-power-menu
        pinentry-rofi
      ];

      pass = {
        enable = true;

        stores = [
          "$XDG_DATA_HOME/password-store"
        ];

        extraConfig = "";
      };
    };
  };
}
