{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.gaming;

  mkDefaultEnable =
    description:
    mkOption {
      type = types.bool;
      default = true;
      inherit description;
    };
in
{
  options.modules.gaming = {
    enable = mkEnableOption "gaming (Steam, GameMode, Gamescope, Proton-GE)";

    gamemode.enable = mkDefaultEnable "GameMode, applied on demand by games that request it";

    gamescope = {
      enable = mkDefaultEnable "Gamescope, for nested use via a Steam launch option";
      session.enable = mkDefaultEnable "the Gamescope session entry in the display manager";
    };

    proton-ge.enable = mkDefaultEnable "GE-Proton as a Steam compatibility tool";
  };

  config = mkIf cfg.enable {
    # Steam ships 32-bit binaries and many games are 32-bit, so both the
    # 64- and 32-bit GL/Vulkan stacks are hard requirements. Set here rather
    # than relying on the host so this module stands on its own.
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.steam = {
      enable = true;

      # winetricks for Proton prefixes; the wrapper locates the right prefix
      # and Proton build, which is tedious to do by hand.
      protontricks.enable = true;

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      # Not hosting Source dedicated servers; this is the only one of these
      # that would invite inbound connections from outside the LAN.
      dedicatedServer.openFirewall = false;

      extraCompatPackages = optionals cfg.proton-ge.enable [ pkgs.proton-ge-bin ];

      # The session is a Gamescope session, so it cannot be on without it.
      gamescopeSession.enable = cfg.gamescope.enable && cfg.gamescope.session.enable;
    };

    programs.gamescope = mkIf cfg.gamescope.enable {
      enable = true;
      # CAP_SYS_NICE for real-time scheduling. If Gamescope refuses to launch
      # from inside Steam's pressure-vessel container, flip this off first.
      capSysNice = true;
    };

    programs.gamemode.enable = cfg.gamemode.enable;

    environment.systemPackages = with pkgs; [
      # FHS shim for non-Nix Linux binaries (itch.io builds, installers)
      steam-run
    ];
  };
}
