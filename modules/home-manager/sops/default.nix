{
  inputs,
  lib,
  pkgs,
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
      dragon = "idjo";
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
        keyFile = "${config.xdg.configHome}/age/key.txt";
      };

      secrets."sshKeys/${sshKey}/id_ed25519" = {
        mode = "0600";
      };

      secrets."sshKeys/${sshKey}/id_ed25519.pub" = {
        mode = "0644";
      };

      secrets."serviceAccounts/ai" = {
        mode = "0600";
      };
    };

    # Fix sops-nix LaunchAgent on macOS: getconf needs system_cmds in PATH
    launchd.agents.sops-nix.config.EnvironmentVariables.PATH = lib.mkIf pkgs.stdenv.isDarwin (
      lib.mkForce "${pkgs.darwin.system_cmds}/bin"
    );
  };
}
