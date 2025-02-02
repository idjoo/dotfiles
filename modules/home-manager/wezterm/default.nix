{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.wezterm;

in
{
  options.modules.wezterm = {
    enable = lib.mkEnableOption "wezterm";
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = cfg.enable;

      extraConfig = # lua
        ''
          local wezterm = require('wezterm')
          local config = {}

          config.default_domain = "local"

          config.window_padding = {
          	left = 6,
          	right = 6,
          	top = 6,
          	bottom = 6,
          }

          config.window_close_confirmation = 'NeverPrompt'

          config.font_size = 13.0
          config.line_height = 1.0
          config.cell_width = 1.0

          config.enable_tab_bar = false
          config.window_decorations = "RESIZE"

          config.audible_bell = "Disabled"

          config.keys = {
            { key = 'L', mods = 'CTRL', action = wezterm.action.ShowDebugOverlay },
          }

          config.font = wezterm.font_with_fallback({
            "RobotoMono Nerd Font Mono",
            "DankMono Nerd Font Mono",
            "Font Awesome 6 Free",
            "Font Awesome 6 Brands",
          })

          return config
        '';
    };
  };
}
