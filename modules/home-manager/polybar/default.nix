{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.polybar;

  herbstluftwm = pkgs.writeShellScriptBin "herbstluftwm.sh" ''
    MON_IDX="0"
    mapfile -t MONITOR_LIST < <(${pkgs.polybar}/bin/polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1)
    for (( i=0; i<$((''${#MONITOR_LIST[@]})); i++ )); do
      [[ ''${MONITOR_LIST[''${i}]} == "$MONITOR" ]] && MON_IDX="$i"
    done;

    herbstclient --idle "tag_*" 2>/dev/null | {
      while true; do
        # Read tags into $tags as array
        IFS=$'\t' read -ra tags <<< "$(herbstclient tag_status "''${MON_IDX}")"

        {
          for i in "''${tags[@]}" ; do
            # Read the prefix from each tag and render them according to that prefix
            case ''${i:0:1} in
              '.')
                # the tag is empty
                # echo "%{A1:herbstclient focus_monitor ''${MON_IDX}; herbstclient use ''${i:1}:}%{B#4c594c} ''${i:1} %{B-}%{A}"
                echo "%{F#4C594C}  %{F-}"
                ;;

              ':')
                # the tag is not empty
                # echo "%{A1:herbstclient focus_monitor ''${MON_IDX}; herbstclient use ''${i:1}:}%{B#354535} ''${i:1} %{B-}%{A}"
                echo "%{F#4C594C}  %{F-}"
                ;;

              '#')
                # the tag is viewed on the specified MONITOR and it is focused.
                # echo "%{A1:herbstclient focus_monitor ''${MON_IDX}; herbstclient use ''${i:1}:}%{B#738f54} ''${i:1} %{B-}%{A}"
                echo "%{F#738F54}  %{F-}"
                ;;

              '!')
                # urgent window
                # echo "%{A1:herbstclient focus_monitor ''${MON_IDX}; herbstclient use ''${i:1}:}%{B#D16969} ''${i:1} %{B-}%{A}"
                echo "%{F#D16969}  %{F-}"
                ;;

              '+')
                # the tag is viewed on the specified MONITOR, but this monitor is not focused.
                ;;

              '-')
                # the tag is viewed on a different MONITOR, but this monitor is not focused.
                ;;

              '%')
                # the tag is viewed on a different MONITOR and it is focused.
                ;;
            esac

            # focus the monitor of the current bar before switching tags
            # echo "%{A1:herbstclient focus_monitor ''${MON_IDX}; herbstclient use ''${i:1}:}  ''${i:1}  %{A -u -o F- B-}"
          done

          # reset foreground and background color to default
          echo "%{F-}%{B-}"
        } | tr -d "\n"

        echo

        # wait for next event from herbstclient --idle
        read -r || break
      done
    } 2>/dev/null
  '';

  pipewire = pkgs.writeShellScriptBin "pipewire.sh" ''
    VOLUME=$(${pkgs.pamixer}/bin/pamixer --get-volume-human)

    case $1 in
      "--up")
        ${pkgs.pamixer}/bin/pamixer --increase 10
        ;;
      "--down")
        ${pkgs.pamixer}/bin/pamixer --decrease 10
        ;;
      "--mute")
        ${pkgs.pamixer}/bin/pamixer --toggle-mute
        ;;
      *)
        echo "''${VOLUME}"
    esac
  '';
in
{
  options.modules.polybar = {
    enable = mkEnableOption "polybar";
  };
  config = mkIf cfg.enable {
    services.polybar = {
      enable = cfg.enable;

      script = "${pkgs.polybar}/bin/polybar main";

      settings = {
        colors = {
          # config.stylix.palette.base00
          background.text = "#1f281f";
          background.alt = "#444";
        };

        "bar/main" = {
          width = "100%";
          height = 25;
          radius = 0.0;
          fixed.center = true;

          background = "#1f281f";
          foreground = "#${config.lib.stylix.colors.base05}";

          line.size = 0;
          border.size = 0;

          padding = {
            left = 1;
            right = 1;
          };

          module.margin = {
            left = 1;
            right = 1;
          };

          font = [
            "RobotoMono Nerd Font:pixelsize=11;2"
            "DankMono Nerd Font:pixelsize=13;2"
            "FiraCode Nerd Font:pixelsize=13;2"
            "Font Awesome 6 Free"
            "Font Awesome 6 Brands"
          ];

          modules = {
            left = "distro date xwindow";
            center = "hlwm";
            right = "bluetooth backlight pipewire cpu memory temperature wireless battery";
          };
        };

        "global/wm" = {
          margin = {
            top = 0;
            bottom = 0;
          };
        };

        "module/distro" = {
          type = "custom/script";
          exec = ''echo ""'';
        };

        "module/date" = {
          type = "internal/date";
          interval = 5;
          date = "%A, %d-%b-%y";
          time = "%H:%M";
          label = " %date% %time% ";
          format = {
            prefix = {
              text = "  ";
              foreground = "#${config.lib.stylix.colors.base0D}";
            };
            background = "#${config.lib.stylix.colors.base02}";
          };
        };

        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:60:...%";
        };

        "module/hlwm" = {
          type = "custom/script";
          exec = "${herbstluftwm}/bin/herbstluftwm.sh";
          tail = true;
        };

        "module/bluetooth" = {
          type = "custom/script";
          exec = "${pkgs.rofi-bluetooth}/bin/rofi-bluetooth --status";
          interval = 1;
        };

        "module/backlight" = {
          type = "internal/backlight";
          use.actual-brightness = true;
          label = "%percentage%%";

          format = {
            text = "<label>";
            prefix = {
              text = "󰃠 ";
              foreground = "#${config.lib.stylix.colors.base0A}";
            };
          };
        };

        "module/pipewire" = {
          type = "custom/script";
          exec = "${pipewire}/bin/pipewire.sh";
          label = "%output%";
          interval = 2;
          format = {
            prefix = {
              text = "  ";
              foreground = "#${config.lib.stylix.colors.base0B}";
            };
          };
        };

        "module/cpu" = {
          type = "internal/cpu";
          interval = 0.5;
          format = "<ramp-load> <label>";
          ramp.load = {
            text = [
              "▁"
              "▂"
              "▃"
              "▄"
              "▅"
              "▆"
              "▇"
              "█"
            ];
            foreground = "#${config.lib.stylix.colors.base0C}";
          };
        };

        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          label = "%percentage_used%%";
          format.prefix = {
            text = "󰍛  ";
            foreground = "#${config.lib.stylix.colors.base0D}";
            font = 2;
          };
        };

        "module/temperature" = {
          type = "internal/temperature";
          thermal.zone = 0;
          warn.temperatur = 90;

          format = {
            text = "<ramp> <label>";
            warn = "<ramp> <label-warn>";
          };

          label = {
            text = "%temperature-c%";
            warn = {
              text = "%temperature-c%";
              foreground = "#${config.lib.stylix.colors.base0E}";
            };
          };

          ramp = {
            text = [
              ""
              ""
              ""
              ""
              ""
            ];
            foreground = "#${config.lib.stylix.colors.base0E}";
          };
        };

        "module/wireless" = {
          type = "internal/network";
          interface-type = "wireless";

          format = {
            connected = "<ramp-signal> <label-connected>";
            disconnected = {
              text = "<label-disconnected>";
              foregound = "#${config.lib.stylix.colors.base0F}";
            };
          };

          label = {
            connected = "%essid%";
            disconnected = {
              text = "N/A";
              foreground = "#${config.lib.stylix.colors.base0F}";
            };
          };

          ramp.signal = {
            text = [ " " ];
            foreground = "#${config.lib.stylix.colors.base0F}";
          };
        };

        "module/battery" = {
          type = "internal/battery";
          full.at = 100;
          low.at = 20;
          adapter = "AC";
          battery = "BAT0";

          format = {
            charging = "<animation-charging> <label-charging>";
            discharging = "<animation-discharging> <label-discharging>";
            full.prefix = {
              text = "";
              foreground = "#${config.lib.stylix.colors.base0B}";
            };
          };

          animation = {
            charging = {
              text = [
                "󰢜"
                "󰂆"
                "󰂇"
                "󰂈"
                "󰢝"
                "󰂉"
                "󰢞"
                "󰂊"
                "󰂋"
                "󰂅"
              ];
              foreground = "#${config.lib.stylix.colors.base0B}";
            };

            discharging = {
              text = [
                "󰁹"
                "󰂂"
                "󰂁"
                "󰂀"
                "󰁿"
                "󰁾"
                "󰁽"
                "󰁼"
                "󰁻"
                "󰁺"
              ];
              foreground = "#${config.lib.stylix.colors.base08}";
            };
          };
        };
      };
    };
  };
}
