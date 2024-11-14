{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.lazygit;
in
{
  options.modules.lazygit = {
    enable = mkEnableOption "lazygit";
  };
  config = mkIf cfg.enable {
    programs.lazygit = {
      enable = cfg.enable;
    };
  };
}
