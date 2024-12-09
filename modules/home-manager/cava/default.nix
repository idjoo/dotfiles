{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.cava;
in
{
  options.modules.cava = {
    enable = mkEnableOption "cava";
  };
  config = mkIf cfg.enable {
    programs.cava = {
      enable = cfg.enable;

      settings = {
        general = {
          framerate = 60;
        };

        color = {
          gradient = 1;
          gradient_count = 8;
          gradient_color_1 = "'#${config.lib.stylix.colors.base01}'";
          gradient_color_2 = "'#${config.lib.stylix.colors.base02}'";
          gradient_color_3 = "'#${config.lib.stylix.colors.base03}'";
          gradient_color_4 = "'#${config.lib.stylix.colors.base04}'";
          gradient_color_5 = "'#${config.lib.stylix.colors.base05}'";
          gradient_color_6 = "'#${config.lib.stylix.colors.base06}'";
          gradient_color_7 = "'#${config.lib.stylix.colors.base07}'";
          gradient_color_8 = "'#${config.lib.stylix.colors.base08}'";
        };
      };
    };
  };
}
