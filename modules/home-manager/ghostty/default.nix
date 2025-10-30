{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.ghostty;

  shaders = pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "4faa83e4b9306750fc8de64b38c6f53c57862db8";
    hash = "sha256-ruhEqXnWRCYdX5mRczpY3rj1DTdxyY3BoN9pdlDOKrE=";
  };

in
{
  options.modules.ghostty = {
    enable = mkEnableOption "ghostty";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = cfg.enable;

      package = mkIf pkgs.stdenv.isDarwin null;

      clearDefaultKeybinds = false;

      settings = {
        theme = "stylix";
        background = "${config.lib.stylix.colors.base00}";
        foreground = "${config.lib.stylix.colors.base05}";

        font-family = "RobotoMono Nerd Font Mono";
        font-size = 13;

        selection-invert-fg-bg = true;

        cursor-style = "block";
        cursor-invert-fg-bg = true;
        cursor-style-blink = false;

        scrollback-limit = 99999999;

        working-directory = "home";

        window-inherit-font-size = true;
        window-decoration = false;
        window-padding-x = 1;
        window-padding-y = 1;
        window-padding-balance = true;
        focus-follows-mouse = false;
        confirm-close-surface = false;

        clipboard-read = "allow";
        clipboard-write = "allow";
        clipboard-paste-protection = true;
        clipboard-paste-bracketed-safe = true;
        clipboard-trim-trailing-spaces = true;
        copy-on-select = false;

        image-storage-limit = 320000000;

        shell-integration = "zsh";
        shell-integration-features = "no-cursor,sudo,title,ssh-terminfo,ssh-env";

        custom-shader-animation = "always";
        custom-shader = [
          "${shaders}/cursor_warp.glsl"
          "${shaders}/ripple_rectangle_cursor.glsl"
        ];

        auto-update = "check";
      };
    };
  };
}
