{
  inputs,
  outputs,
  pkgs,
  config,
  rootPath,
  ...
}:
{
  imports = [
    outputs.darwinModules
    inputs.home-manager.darwinModules.default
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      inputs.nur.overlays.default
    ];

    config = {
      allowUnfreePredicate = (pkg: true);
    };
  };

  # Hostname
  networking.hostName = "snake";

  # Time Zone
  time.timeZone = "Asia/Jakarta";

  # Users
  system.primaryUser = "${outputs.username}";
  users.users.${outputs.username} = {
    description = "Adrianus Vian Habirowo";
    shell = pkgs.zsh;
    home = "/Users/${outputs.username}";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    font-awesome
  ];

  # Packages
  environment.systemPackages = [
    pkgs.google-chrome
  ];

  # Keyboard Remap
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
    swapLeftCommandAndLeftAlt = true;
  };

  # Disable Animation
  system.defaults.universalaccess.reduceMotion = true;

  # Trackpad
  system.defaults.trackpad = {
    Clicking = true;
    Dragging = true;
  };

  # Modules
  modules = {
    aerospace.enable = true;
    comma.enable = true;
    homebrew.enable = true;
    nix.enable = true;
    podman.enable = true;
    ssh.enable = true;
    stylix.enable = true;
    tailscale.enable = true;

    utils = {
      enable = true;
      gui.enable = true;
      custom.enable = false;
    };
  };

  # Home Manager
  home-manager = {
    backupFileExtension = "hm.bak";
    extraSpecialArgs = {
      inherit inputs outputs rootPath;
      inherit (config.networking) hostName;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ${outputs.username} = import ./home.nix;
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
