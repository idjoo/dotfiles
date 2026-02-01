# Dragon - GCP cloud VM configuration
# Based on ox, but without physical hardware-config.nix
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
  ];

  nixpkgs = {
    hostPlatform = "x86_64-linux";

    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.llm-agents
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
          "https://cache.numtide.com"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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

  # hostname
  networking.hostName = "dragon";

  # Enable networking (GCP handles DHCP)
  networking.networkmanager.enable = false;

  # services
  services = {
    openssh.enable = true;
  };

  virtualisation = {
    docker.enable = true;
  };

  # firewall (GCP has its own firewall, but keep this for defense in depth)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
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

  # user accounts
  users.users.${outputs.username} = {
    isNormalUser = true;
    description = "Adrianus Vian Habirowo";
    extraGroups = [
      "wheel"
      "docker"
    ];
    packages = [ ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  # packages
  environment.systemPackages = with pkgs; [
    nurl
  ];

  programs = {
    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  modules = {
    comma.enable = true;
    tailscale.enable = true;
    utils = {
      enable = true;
      gui.enable = false;
    };
    sops.enable = true;
  };

  system.stateVersion = "23.11";
}
