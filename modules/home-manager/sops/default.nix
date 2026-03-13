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

  identity =
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
        keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      };

      secrets."sshKeys/${identity}/id_ed25519" = {
        mode = "0600";
      };

      secrets."sshKeys/${identity}/id_ed25519.pub" = {
        mode = "0644";
      };

      secrets."gpgKeys/${identity}/private" = {
        mode = "0600";
      };

      secrets."gpgKeys/${identity}/public" = {
        mode = "0644";
      };

      secrets."serviceAccounts/ai" = {
        mode = "0600";
      };

      secrets."serviceAccounts/ai.bak" = {
        mode = "0600";
      };
    };

    # Fix sops-nix LaunchAgent on macOS: include both nix-provided getconf and
    # Apple system tools (hdiutil, etc.) used by sops-install-secrets.
    launchd.agents.sops-nix.config.EnvironmentVariables.PATH = lib.mkIf pkgs.stdenv.isDarwin (
      lib.mkForce "${pkgs.darwin.system_cmds}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    );
  };
}
