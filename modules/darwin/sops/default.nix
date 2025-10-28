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
      ox = "idjo";
      horse = "devoteam";
      snake = "devoteam";
    }
    ."${config.networking.hostName}";
in
{
  imports = [
    inputs.sops-nix.darwinModules.sops
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
        owner = "${outputs.username}";
        mode = "0600";
      };

      secrets."sshKeys/${sshKey}/id_ed25519.pub" = {
        owner = "${outputs.username}";
        mode = "0644";
      };
    };
  };
}
