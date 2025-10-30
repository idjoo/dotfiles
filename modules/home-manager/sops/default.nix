{
  inputs,
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
      ox = "idjo";
      horse = "devoteam";
      snake = "devoteam";
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
        keyFile = "${config.xdg.configHome}/age/keys.txt";
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
