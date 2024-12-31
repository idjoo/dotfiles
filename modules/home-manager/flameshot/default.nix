{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.flameshot;
in
{
  options.modules.flameshot = {
    enable = mkEnableOption "flameshot";
  };
  config = mkIf cfg.enable {
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };

    services.flameshot = {
      enable = cfg.enable;

      settings = {
        General = {
          savePath = "${config.home.homeDirectory}/pictures/screenshots";
          savePathFixed = false;
          uiColor = "#${config.lib.stylix.colors.base01}";
          contrastUiColor = "#${config.lib.stylix.colors.base02}";
          drawColor = "#${config.lib.stylix.colors.base03}";
          disabledTrayIcon = true;
          showStartupLaunchMessage = false;
          saveAsFileExtension = ".png";
        };
      };
    };
  };
}
