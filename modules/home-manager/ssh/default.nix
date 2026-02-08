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
        };
      };
    };

    programs.keychain = {
      enable = true;
      keys = [
        "${config.sops.secrets."sshKeys/${identity}/id_ed25519".path}"
      ];
    };
  };
}
