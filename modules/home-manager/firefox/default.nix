{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.firefox;
in
{
  options.modules.firefox = {
    enable = mkEnableOption "firefox";
  };
  config = mkIf cfg.enable {
    # No profile is declared here, so stylix has nothing to theme into; same
    # treatment as the zen-browser module.
    stylix.targets.firefox.enable = false;

    programs.firefox = {
      enable = cfg.enable;

      # Adopt the post-26.05 XDG default explicitly. Nothing to migrate: there
      # is no `~/.mozilla/firefox`, only home-manager's native-messaging-hosts,
      # which this option does not relocate.
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };
}
