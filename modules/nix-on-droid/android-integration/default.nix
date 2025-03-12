{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.android-integration;
in
{
  options.modules.android-integration = {
    enable = mkEnableOption "android-integration";
  };
  config = mkIf cfg.enable {
    android-integration = {
      am.enable = cfg.enable;
      termux-open.enable = cfg.enable;
      termux-open-url.enable = cfg.enable;
      termux-reload-settings.enable = cfg.enable;
      termux-setup-storage.enable = cfg.enable;
      unsupported.enable = cfg.enable;
    };
  };
}
