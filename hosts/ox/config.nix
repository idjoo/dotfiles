{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  rootPath,
  ...
}:
{
  imports = [
    outputs.nixosModules

    inputs.home-manager.nixosModules.home-manager

    ./hardware-config.nix
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

      channel.enable = false;

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # hostname
  networking.hostName = "ox";

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

    displayManager.startx.enable = true;
  };

  # user accounts
  users.users.${outputs.username} = {
    isNormalUser = true;
    description = "Adrianus Vian Habirowo";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  # packages
  environment.systemPackages = with pkgs; [
    nurl
  ];

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    font-awesome
  ];

  programs = {
    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;

    virtualHosts."os.wyvern-vector.ts.net" = {
      locations."~ /api/whatsapp/(.*)" = {
        proxyPass = "http://127.0.0.1:8000/$1";
      };

      locations."~ /api/chatbot/(.*)" = {
        proxyPass = "http://127.0.0.1:8001/$1";
      };

      locations."~ /chatbot/(.*)" = {
        proxyPass = "http://127.0.0.1:8002/$1";
        proxyWebsockets = true;
      };
    };
  };

  modules = {
    comma.enable = true;
    nh.enable = true;
    stylix.enable = true;
    tailscale.enable = true;
    utils = {
      enable = true;
      gui.enable = false;
      custom.enable = false;
    };
    xremap.enable = true;
    sops.enable = true;
  };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
