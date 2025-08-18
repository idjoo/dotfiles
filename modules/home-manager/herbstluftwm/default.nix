{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.herbstluftwm;

  polybar = pkgs.writeShellScriptBin "panel.sh" ''
    pkill polybar

    while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

    polybar main -r 2>&1 | tee -a /tmp/polybar.log & disown
  '';

  wallpaper = pkgs.fetchurl {
    url = "https://images.pexels.com/photos/1072179/pexels-photo-1072179.jpeg";
    sha256 = "sha256-RqhRCDrgC/7oFu5UZ5nj5FHIib2yzbZ94SpGF54Tm08=";
  };
in
{
  options.modules.herbstluftwm = {
    enable = mkEnableOption "herbstluftwm";
  };

  config = mkIf cfg.enable {
    xsession.windowManager.herbstluftwm = {
      enable = cfg.enable;
      tags = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "0"
      ];
      keybinds = {
        Mod4-Shift-q = "quit";
        Mod4-Shift-r = "reload";
        Mod4-w = "close";

        # terminal
        Mod4-Return = "spawn ${pkgs.ghostty}/bin/ghostty";

        # workspaces
        Mod4-1 = "use_index 0";
        Mod4-2 = "use_index 1";
        Mod4-3 = "use_index 2";
        Mod4-4 = "use_index 3";
        Mod4-5 = "use_index 4";
        Mod4-6 = "use_index 5";
        Mod4-7 = "use_index 6";
        Mod4-8 = "use_index 7";
        Mod4-9 = "use_index 8";
        Mod4-0 = "use_index 9";

        Mod4-Shift-1 = "move_index 0";
        Mod4-Shift-2 = "move_index 1";
        Mod4-Shift-3 = "move_index 2";
        Mod4-Shift-4 = "move_index 3";
        Mod4-Shift-5 = "move_index 4";
        Mod4-Shift-6 = "move_index 5";
        Mod4-Shift-7 = "move_index 6";
        Mod4-Shift-8 = "move_index 7";
        Mod4-Shift-9 = "move_index 8";
        Mod4-Shift-0 = "move_index 9";

        # window movement
        Mod4-h = "focus --level=all left";
        Mod4-j = "focus --level=all down";
        Mod4-k = "focus --level=all up";
        Mod4-l = "focus --level=all right";

        Mod4-Shift-h = "shift left";
        Mod4-Shift-j = "shift down";
        Mod4-Shift-k = "shift up";
        Mod4-Shift-l = "shift right";

        Mod1-Tab = "use_previous";

        Mod4-space = ''
          or , and . compare tags.focus.curframe_wcount = 2 \
            . cycle_layout +1 grid max \
            , cycle_layout +1
        '';

        Mod4-f = "set_attr clients.focus.floating toggle";
        Mod4-Shift-f = "fullscreen toggle";

        # rofi
        Mod4-d = "spawn rofi -show drun -modi drun";
        Mod4-p = "spawn ${pkgs.rofi-pass}/bin/rofi-pass";
        Mod4-a = "spawn ${pkgs.ani-cli}/bin/ani-cli --rofi --skip";
        Mod4-b = "spawn ${pkgs.rofi-bluetooth}/bin/rofi-bluetooth";
        Mod4-e = "spawn rofi -show emoji -modi emoji";
        Mod4-c = ''spawn rofi -show calc -modi calc -no-show-match -no-sort -calc-command " echo - n '{ result }' | xsel --clipboard"'';

        # xf86
        XF86MonBrightnessUp = "spawn ${pkgs.acpilight}/bin/xbacklight -inc 10";
        XF86MonBrightnessDown = "spawn ${pkgs.acpilight}/bin/xbacklight -dec 10";
        XF86AudioMute = "spawn ${pkgs.pamixer}/bin/pamixer --toggle-mute";
        XF86AudioRaiseVolume = "spawn ${pkgs.pamixer}/bin/pamixer --increase 5";
        XF86AudioLowerVolume = "spawn ${pkgs.pamixer}/bin/pamixer --decrease 5";
        XF86AudioPlay = "spawn ${pkgs.playerctl}/bin/playerctl play-pause";
        XF86AudioNext = "spawn ${pkgs.playerctl}/bin/playerctl next";
        XF86AudioPrev = "spawn ${pkgs.playerctl}/bin/playerctl previous";

        Print = "spawn ${pkgs.flameshot}/bin/flameshot gui 2>/tmp/flameshot.log 1>/tmp/flameshot.log";
      };

      mousebinds = {
        Mod4-B1 = "move";
        Mod4-B2 = "zoom";
        Mod4-B3 = "resize";
      };

      rules = [
        "focus=on"
        "floatplacement=smart"
        "fixedsize floating=on"
        "instance=firefox tag=0"
        "instance=google-chrome tag=0"
        "instance=telegram-desktop tag=7"
      ];

      settings = {
        show_frame_decorations = true;
        auto_detect_monitors = true;
        auto_detect_panels = true;
        default_frame_layout = "grid";
        focus_follows_mouse = false;
        frame_active_opacity = 0;
        frame_normal_opacity = 0;
        frame_border_width = 0;
        frame_gap = 0;
        frame_padding = 0;
        frame_transparent_width = 0;
        mouse_recenter_gap = 0;
        smart_frame_surroundings = false;
        smart_window_surroundings = false;
        tree_style = ''╾│ ├└╼─┐'';
        window_gap = 0;
      };

      extraConfig = ''
        herbstclient attr theme.active.color '#${config.lib.stylix.colors.base0B}'
        herbstclient attr theme.active.border_width 1

        ${pkgs.feh}/bin/feh --no-fehbg --bg-fill "${wallpaper}"
        ${polybar}/bin/panel.sh

        ${pkgs.dunst}/bin/dunstify "herbstluftwm reloaded!"
      '';
    };
  };
}
