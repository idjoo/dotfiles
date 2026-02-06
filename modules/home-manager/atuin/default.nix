{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.atuin;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.modules.atuin = {
    enable = mkEnableOption "atuin";
  };
  config = mkIf cfg.enable {
    sops.secrets."keys/atuin" = { };

    programs.atuin = {
      enable = cfg.enable;

      daemon = {
        enable = true;
      };

      settings = {
        keymap_mode = "vim-insert";
        update_check = false;
        sync.records = true;
        key_path = config.sops.secrets."keys/atuin".path;
      };
    };
  };
}
