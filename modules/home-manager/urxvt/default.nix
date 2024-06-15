{ lib
, config
, ...
}:
let
  cfg = config.modules.urxvt;

in
{
  options.modules.urxvt = { enable = lib.mkEnableOption "urxvt"; };
  config = lib.mkIf cfg.enable {
    programs.urxvt = {
      enable = true;

      iso14755 = false;

      extraConfig = {
        perl-ext-common = "default,matcher";
        url-launcher = "/run/current-system/sw/bin/xdg-open";
        "matcher.button" = 1;
      };

      fonts = [
        "xft:DankMono Nerd Font Mono:size=12"
        "xft:FiraCode Nerd Font Mono:size=12"
        "xft:Font Awesome 6 Free:style=Solid"
        "xft:Font Awesome 6 Brands:style=Solid"
      ];

      keybindings = {
        "Shift-Control-C" = "eval:selection_to_clipboard";
        "Shift-Control-V" = "eval:paste_clipboard";
      };

      scroll = {
        bar = {
          enable = false;
        };
      };
    };
  };
}
