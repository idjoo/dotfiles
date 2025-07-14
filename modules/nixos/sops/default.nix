{
  inputs,
  outputs,
  lib,
  config,
  rootPath,
  ...
}:
with lib;
let
  cfg = config.modules.sops;

  sshKey =
    {
      horse = "devoteam";
      ox = "idjo";
    }
    ."${config.networking.hostName}";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.modules.sops = {
    enable = mkEnableOption "sops";
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = rootPath + /secrets/config.yaml;
      defaultSopsFormat = "yaml";

      age = {
        keyFile = "/var/lib/age/key.txt";
      };

      secrets."sshKeys/${sshKey}/private" = {
        owner = "${outputs.username}";
        path = "/home/${outputs.username}/.ssh/id_ed25519";
      };

      secrets."sshKeys/${sshKey}/public" = {
        owner = "${outputs.username}";
        path = "/home/${outputs.username}/.ssh/id_ed25519.pub";
      };
    };
  };
}
