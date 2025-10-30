{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.homebrew;
in
{
  options.modules.homebrew = {
    enable = mkEnableOption "homebrew";
  };

  config = mkIf cfg.enable {
    system.activationScripts.homebrew.text = lib.mkIf config.homebrew.enable (
      lib.mkBefore ''
        if [[ ! -f "${config.homebrew.brewPrefix}/brew" ]]; then
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
      ''
    );

    homebrew = {
      enable = cfg.enable;

      # Don't quarantine apps installed by homebrew with gatekeeper
      caskArgs.no_quarantine = true;

      # Remove all homebrew packages when they get removed from the configuration
      onActivation.cleanup = "uninstall";

      casks = [
        "ghostty"
        "raycast"
        "shottr"
      ];
    };
  };
}
