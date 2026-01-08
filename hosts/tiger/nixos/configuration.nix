{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    outputs.nixosModules

    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        trusted-users = [ "${outputs.username}" ];

        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        experimental-features = "nix-command flakes";

        flake-registry = "";

        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
      };

      gc = {
        automatic = false;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      channel.enable = false;

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
  };

  # hostname
  networking.hostName = "tiger";

  # proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # services
  services = {
    openssh.enable = true;
  };

  # firewall
  networking.firewall = {
    enable = false;
    # allowedTCPPorts = [ ... ];
    # allowedUDPPorts = [ ... ];
  };

  # time zone
  time.timeZone = "Asia/Jakarta";

  # locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # x11
  services.xserver = {
    enable = true;
    autorun = false;

    xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape";
    };

    desktopManager.xterm.enable = true;

    displayManager.startx.enable = true;

    windowManager.herbstluftwm.enable = true;
  };

  # user accounts
  users.users.${outputs.username} = {
    isNormalUser = true;
    description = "Adrianus Vian Habirowo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "video"
      "adbusers"
    ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  # packages
  environment.systemPackages = with pkgs; [
    google-chrome
    hicolor-icon-theme
  ];

  # fonts
  fonts.packages = with pkgs; [
    dank-mono-nerdfont
    fira-code-nerdfont
    terminus-nerdfont
    font-awesome
  ];

  programs = {
    zsh.enable = true;
  };
  environment.pathsToLink = [ "/share/zsh" ];

  virtualisation = {
    docker.enable = true;
  };

  modules = {
    nh.enable = true;
    stylix.enable = true;
    pipewire.enable = true;
    tailscale.enable = true;
    utils.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
