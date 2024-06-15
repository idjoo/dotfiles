{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.herbstluftwm;
in {
  options.modules.herbstluftwm = {enable = mkEnableOption "herbstluftwm";};
  config = mkIf cfg.enable {
    xsession.windowManager.herbstluftwm = {
      enable = true;
      tags = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "0"];
      keybinds = {
        Mod4-Shift-q = "quit";
        Mod4-Shift-r = "reload";
        Mod4-w = "close";

        # terminal
        Mod4-Return = "spawn ${pkgs.wezterm}/bin/wezterm";

        # rofi
        Mod4-d = "spawn ${pkgs.rofi}/bin/rofi -show drun -modi drun";

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

        Mod4-h = "focus left";
        Mod4-j = "focus down";
        Mod4-k = "focus up";
        Mod4-l = "focus right";

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

        ## xf86
        #XF86MonBrightnessUp spawn xbacklight -inc 10
        #XF86MonBrightnessDown spawn xbacklight -dec 10
        #XF86AudioMute spawn pamixer --toggle-mute
        #XF86AudioRaiseVolume spawn pamixer --increase 5
        #XF86AudioLowerVolume spawn pamixer --decrease 5
        #
        #XF86AudioPlay spawn playerctl play-pause
        #XF86AudioNext spawn playerctl next
        #XF86AudioPrev spawn playerctl previous
        #
        #XF86Launch1 spawn rofi -show calc -modi calc -no-show-match -no-sort -calc-command "echo -n '{result}' | xsel --clipboard"
        #Print spawn flameshot gui
        #Control-Print spawn color-picker
        #Mod4-p spawn rofi-pass
        #Mod4-a spawn ani-cli --rofi --skip
        #Mod4-b spawn rofi-bluetooth
        #Mod4-e spawn rofi -show emoji -modi emoji
        #
        #Mod4-Print spawn screencast
        #Mod1-Print spawn screencast -s
        #Mod4-backslash spawn screencast-stop
        #
        ## lock screen
        #Mod1-Shift-l spawn betterlockscreen --lock
        #
        ## splitting frames
        ## create an empty frame at the specified direction
        #Mod4-u split bottom 0.5
        #Mod4-o split right 0.5
        ## let the current frame explode into subframes
        #Mod4-Control-space split explode
        #
        ## resizing frames and floating clients
        #resizestep=0.01
        #Mod1-h resize left +"$resizestep"
        #Mod1-j resize down +"$resizestep"
        #Mod1-k resize up +"$resizestep"
        #Mod1-l resize right +"$resizestep"
      };

      mousebinds = {
        Mod4-B1 = "move";
        Mod4-B2 = "zoom";
        Mod4-B3 = "resize";
      };

      rules = [
        "focus=on"
        "floatplacement=smart"
        "class=Google-chrome tag=0"
      ];

      settings = {
        always_show_frame = "on";
        default_frame_layout = "grid";
        frame_bg_active_color = "#292229";
        frame_bg_normal_color = "#565656";
        frame_bg_transparent = "on";
        frame_border_active_color = "#222222";
        frame_border_normal_color = "#101010";
        frame_border_width = 1;
        frame_gap = 0;
        frame_padding = 0;
        frame_transparent_width = 5;
        mouse_recenter_gap = 0;
        smart_frame_surroundings = "off";
        smart_window_surroundings = "off";
        tree_style = ''╾│ ├└╼─┐'';
        window_gap = 0;
      };

      extraConfig = ''
        systemctl --user restart polybar

        hc() {
            herbstclient "$@"
        }

        hc attr theme.active.color '#345F0C'
        hc attr theme.active.inner_color '#789161'
        hc attr theme.active.outer_width 1
        hc attr theme.background_color '#141414'
        hc attr theme.border_width 2
        hc attr theme.floating.border_width 2
        hc attr theme.floating.outer_color black
        hc attr theme.floating.outer_width 0
        hc attr theme.floating.reset 1
        hc attr theme.inner_color black
        hc attr theme.inner_width 0
        hc attr theme.normal.color '#4c594c'
        hc attr theme.normal.inner_color '#606060'
        hc attr theme.normal.title_color '#898989'
        hc attr theme.padding_top 0 # space below the title's baseline (i.e. text depth)
        hc attr theme.tiling.reset 1
        hc attr theme.title_color '#000000'
        hc attr theme.title_height 0
        hc attr theme.urgent.color '#7811A1'
        hc attr theme.urgent.inner_color '#9A65B0'
      '';
    };
  };
}
