{
  lib,
  config,
  inputs,
  hostName,
  ...
}:
with lib;
let
  cfg = config.modules.ssh;

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

  options.modules.ssh = {
    enable = mkEnableOption "ssh";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = cfg.enable;
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
          forwardAgent = true;
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };
    };

    programs.keychain = {
      enable = true;
      keys = [
        "${config.sops.secrets."sshKeys/${sshKey}/id_ed25519".path}"
      ];
    };
  };
}
