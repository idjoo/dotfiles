{ lib
, config
, ...
}:
with lib; let
  cfg = config.modules.btop;
in
{
  options.modules.btop = { enable = mkEnableOption "btop"; };
  config = mkIf cfg.enable {
    programs.btop = {
      enable = cfg.enable;
      settings = { };
    };
  };
}
