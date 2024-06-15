{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.stylix;
in {
  options.modules.stylix = {
    enable = mkOption {
      type = lib.types.bool;
      default = true;
      example = true;
      description = "stylix";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      image = pkgs.fetchurl {
        url = "https://ember.idjo.cc/images/wallpaper.png";
        sha256 = "09f7fd058106437ff791cf97b5e408019622914f5f831358a44e5b108e5e5f99";
      };

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

      override = {
        base00 = "#293329"; # base
        base01 = "#3e4d3e"; # mantle
        base02 = "#5f6d5f"; # surface0
        base03 = "#738b73"; # surface1
        base04 = "#5f7f6b"; # surface2
      };

      fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };

        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };

        monospace = {
          package = pkgs.fira-code-nerdfont;
          name = "FiraCode Nerd Font Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };

    # stylix.base16Scheme = {
    #   base00 = "#293329"; # base
    #   base01 = "#3e4d3e"; # mantle
    #   base02 = "#5f6d5f"; # surface0
    #   base03 = "#738b73"; # surface1
    #   base04 = "#5f7f6b"; # surface2
    #   base05 = "#c6d0f5"; # text
    #   base06 = "#f2d5cf"; # rosewater
    #   base07 = "#babbf1"; # lavender
    #   base08 = "#e78284"; # red
    #   base09 = "#ef9f76"; # peach
    #   base0A = "#e5c890"; # yellow
    #   base0B = "#a6d189"; # green
    #   base0C = "#81c8be"; # teal
    #   base0D = "#8caaee"; # blue
    #   base0E = "#ca9ee6"; # mauve
    #   base0F = "#eebebe"; # flamingo
    # };
  };
}
