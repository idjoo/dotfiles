{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.stylix;
in
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  options.modules.stylix = {
    enable = mkEnableOption "stylix";
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = cfg.enable;

      polarity = "dark";

      image = pkgs.fetchurl {
        url = "https://images.pexels.com/photos/1072179/pexels-photo-1072179.jpeg";
        sha256 = "sha256-RqhRCDrgC/7oFu5UZ5nj5FHIib2yzbZ94SpGF54Tm08=";
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
          package = pkgs.nerd-fonts.roboto-mono;
          name = "RobotoMono Nerd Font Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };

    # base00 = base
    # base01 = mantle
    # base02 = surface0
    # base03 = surface1
    # base04 = surface2
    # base05 = text
    # base06 = rosewater
    # base07 = lavender
    # base08 = red
    # base09 = peach
    # base0A = yellow
    # base0B = green
    # base0C = teal
    # base0D = blue
    # base0E = mauve
    # base0F = flamingo
  };
}
