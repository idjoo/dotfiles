{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.eza;
in
{
  options.modules.eza = {
    enable = mkEnableOption "eza";
  };
  config = mkIf cfg.enable {
    programs.eza = {
      enable = cfg.enable;

      git = true;
      icons = "auto";

      extraOptions = [
        "--group"
        "--group-directories-first"
        "--color=always"
      ];
    };
  };
}
