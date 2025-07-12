{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.atuin;
in
{
  options.modules.atuin = {
    enable = mkEnableOption "atuin";
  };
  config = mkIf cfg.enable {
    programs.atuin = {
      enable = cfg.enable;

      daemon = {
        enable = true;
      };

      settings = {
        keymap_mode = "vim-insert";
        update_check = false;
        sync.records = true;
      };
    };
  };
}
