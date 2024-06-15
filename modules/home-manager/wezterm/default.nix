{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.wezterm;
in
{
  options.modules.wezterm = { enable = mkEnableOption "wezterm"; };
  config = mkIf cfg.enable {
    programs.wezterm = {
      enable = true;

      extraConfig = ''
        local config = {}

        config.default_domain = "local"

        config.window_padding = {
        	left = 6,
        	right = 6,
        	top = 6,
        	bottom = 6,
        }

        config.window_close_confirmation = 'NeverPrompt'

        config.font_size = 12.0
        config.line_height = 1.0
        config.cell_width = 1.0

        config.enable_tab_bar = false
        config.window_decorations = "RESIZE"

        config.audible_bell = "Disabled"

        return config
      '';
    };
  };
}
