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
      tiger = "idjo";
      dog = "idjo";
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

      settings = {
        "*" = {
          AddKeysToAgent = "yes";
          ForwardAgent = true;
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
