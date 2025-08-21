{
  inputs,
  outputs,
  lib,
  config,
  rootPath,
  hostName,
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
    ."${hostName}";
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
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

      secrets."sshKeys/${sshKey}/id_ed25519" = {
        mode = "0600";
      };

      secrets."sshKeys/${sshKey}/id_ed25519.pub" = {
        mode = "0644";
      };
    };
  };
}
