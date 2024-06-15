{ lib
, config
, ...
}:
with lib; let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = { enable = mkEnableOption "ssh"; };
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = cfg.enable;
      addKeysToAgent = "yes";
      forwardAgent = true;
    };

    programs.keychain = {
      enable = true;
      keys = [
        "id_ed25519"
      ];
    };
  };
}
