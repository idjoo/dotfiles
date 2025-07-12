{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.nushell;
in
{
  options.modules.nushell = {
    enable = mkEnableOption "nushell";
  };
  config = mkIf cfg.enable {
    home.shell.enableNushellIntegration = true;

    programs.nushell = {
      enable = cfg.enable;

      settings = {
      };
    };
  };
}
