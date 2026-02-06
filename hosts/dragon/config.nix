# Dragon - OCI ARM cloud VM configuration
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  rootPath,
  modulesPath,
  ...
}:
{
  imports = [
    outputs.nixosModules
    ./disko.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs = {
    hostPlatform = "aarch64-linux";

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

  # Boot configuration for OCI
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "usbhid"
    ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # hostname
  networking.hostName = "dragon";

  # Enable networking (OCI handles DHCP)
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  # services
  services = {
    openssh.enable = true;
  };

  virtualisation = {
    docker.enable = true;
  };

  # firewall (OCI has its own firewall, but keep this for defense in depth)
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
    # SSH authorized keys (public keys are not secret, can be hardcoded)
    # These correspond to the private keys managed by sops
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDU/Xo4ax3/WcsICw4thl4oDurw6j2ThuOlcWAxQBQoy adrianus.vian.habirowo@devoteam.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWyabW5NL2Ul6e1/FIn/nbx+Dl1GlpBOtNDRhba6YLd vian@idjo.cc"
    ];
  };

  # Allow root login for nixos-anywhere initial deployment
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDU/Xo4ax3/WcsICw4thl4oDurw6j2ThuOlcWAxQBQoy adrianus.vian.habirowo@devoteam.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWyabW5NL2Ul6e1/FIn/nbx+Dl1GlpBOtNDRhba6YLd vian@idjo.cc"
  ];

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
    xremap.enable = true;
  };

  system.stateVersion = "23.11";
}
