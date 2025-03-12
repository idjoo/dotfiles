{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.rofi;
in
{
  options.modules.rofi = {
    enable = mkEnableOption "rofi";
  };
  config = mkIf cfg.enable {
    programs.rofi = {
      enable = cfg.enable;
      location = "center";

      terminal = "${pkgs.ghostty}/bin/ghostty";

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
          "${config.xdg.dataHome}/pass"
        ];

        extraConfig = ''
          default_user=":filename"
        '';
      };

      theme =
        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            highlight = mkLiteral "bold italic";
            scrollbar = true;
            # border-color = mkLiteral "#${config.lib.stylix.colors.base0B}";
          };

          window = {
            border = 2;
            padding = 2;
          };

          mainbox = {
            border = 0;
            padding = 0;
          };

          message = {
            border = mkLiteral "2px 0 0";
            padding = mkLiteral "1px";
          };

          listview = {
            border = mkLiteral "2px solid 0 0";
            padding = mkLiteral "2px 0 0";
            spacing = mkLiteral "2px";
            scrollbar = mkLiteral "@scrollbar";
          };

          element = {
            border = 0;
            padding = mkLiteral "2px";
          };

          scrollbar = {
            width = mkLiteral "4px";
            border = 0;
            handle-width = mkLiteral "8px";
            padding = 0;
          };

          mode-switcher = {
            border = mkLiteral "2px 0 0";
          };

          inputbar = {
            spacing = 0;
            padding = mkLiteral "2px";
            children = map mkLiteral [
              "prompt"
              "textbox-prompt-sep"
              "entry"
              "case-indicator"
            ];
          };

          "case-indicator, entry, prompt, button" = {
            spacing = 0;
          };

          textbox-prompt-sep = {
            expand = false;
            str = ":";
            margin = mkLiteral "0 0.3em 0 0";
          };

          "element-text, element-icon" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };
        };
    };
  };
}
