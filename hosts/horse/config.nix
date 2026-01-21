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
    outputs.nixosModules

    ./hardware-config.nix
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

  # bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # hostname
  networking.hostName = "horse";

  # proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # services
  services = {
    displayManager = {
      ly = {
        enable = true;
      };
    };

    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # printing auto discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # firewall
  networking.firewall = {
    enable = false;
    # allowedTCPPorts = [ ... ];
    # allowedUDPPorts = [ ... ];
  };

  networking.extraHosts = ''
    34.101.209.86 chatmalika.kai.id
    127.0.0.1 sukha.galeri24.co.id
  '';

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
    autoRepeatDelay = 200;
    autoRepeatInterval = 50;

    desktopManager.xterm.enable = true;
    displayManager.startx.enable = true;
    windowManager.herbstluftwm.enable = true;

    videoDrivers = [ "amdgpu" ];
  };

  services.logind.lidSwitchExternalPower = "ignore";

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
      "kvm"
    ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  # packages
  environment.systemPackages = with pkgs; [
    google-chrome
    telegram-desktop
    hicolor-icon-theme
  ];

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    font-awesome
  ];

  programs = {
    zsh.enable = true;
  };

  virtualisation = {
    docker.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  modules = {
    comma.enable = true;
    nh.enable = true;
    nix.enable = true;
    pipewire.enable = true;
    rclone.enable = true;
    ssh.enable = true;
    stylix.enable = true;
    tailscale.enable = true;
    utils = {
      enable = true;
      gui.enable = true;
    };
    xremap.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
