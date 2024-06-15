{ lib
, config
, ...
}:
with lib; let
  cfg = config.modules.eza;
in
{
  options.modules.eza = { enable = mkEnableOption "eza"; };
  config = mkIf cfg.enable {
    programs.eza = {
      enable = cfg.enable;

      git = true;
      icons = true;

      extraOptions = [
        "--group-directories-first"
        "--color=always"
      ];
    };
  };
}
