{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.tailscale;
  isDragon = config.networking.hostName == "dragon";
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "tailscale";
  };
  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = if isDragon then "server" else "client";
      extraSetFlags = if isDragon then [ "--advertise-exit-node" ] else [ "--exit-node=dragon" ];
    };
  };
}
