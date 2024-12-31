{
  inputs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.ghostty;
in
{
  imports = [
    inputs.ghostty-hm.homeModules.default
  ];

  options.modules.ghostty = {
    enable = mkEnableOption "ghostty";
  };
  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = cfg.enable;

      package = inputs.ghostty.packages.x86_64-linux.default;

      shellIntegration = {
        enable = false;
        enableZshIntegration = true;
      };

      settings = {
        theme = "catppuccin-frappe";
        background = "${config.lib.stylix.colors.base00}";
        foreground = "${config.lib.stylix.colors.base05}";

        font-family = "RobotoMono Nerd Font Mono";
        font-size = 13;

        selection-invert-fg-bg = true;

        cursor-invert-fg-bg = true;
        cursor-style = "block";
        cursor-style-blink = false;

        scrollback-limit = 99999999;

        working-directory = "home";

        window-inherit-font-size = true;
        window-decoration = false;
        window-padding-x = 1;
        window-padding-y = 1;
        window-padding-balance = true;
        focus-follows-mouse = false;

        clipboard-read = "allow";
        clipboard-write = "allow";
        clipboard-paste-protection = true;
        clipboard-paste-bracketed-safe = true;
        clipboard-trim-trailing-spaces = true;
        copy-on-select = false;

        image-storage-limit = 320000000;

        shell-integration = "zsh";
        shell-integration-features = "no-cursor,sudo,title";

        auto-update = "check";
      };
    };
  };
}
