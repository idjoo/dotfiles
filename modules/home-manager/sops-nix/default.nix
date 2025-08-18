{
  lib,
  config,
  inputs,
  outputs,
  ...
}:
with lib;
let
  cfg = config.modules.sops-nix;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.modules.sops-nix = {
    enable = mkEnableOption "sops-nix";
  };
  config = mkIf cfg.enable {
    sops = {
      age.keyFile = "/home/${outputs.username}/.config/sops/age/keys.txt";
    };
  };
}
