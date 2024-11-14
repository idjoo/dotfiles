{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.pipewire;
in
{
  options.modules.pipewire = {
    enable = mkEnableOption "pipewire";
  };
  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pamixer
    ];
  };
}
