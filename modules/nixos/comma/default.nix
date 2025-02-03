{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.comma;
in
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  options.modules.comma = {
    enable = mkEnableOption "comma";
  };

  config = mkIf cfg.enable {
    programs.nix-index-database.comma = {
      enable = cfg.enable;
    };
  };
}
