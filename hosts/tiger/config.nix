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
      outputs.overlays.llm-agents

      inputs.nur.overlays.default
    ];

    config = {
      allowUnfreePredicate = (pkg: true);
    };
  };

  # bootloader
  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
  };

  # hostname
  networking.hostName = "tiger";

  # proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # networking
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

    windowManager.herbstluftwm.enable = true;
  };

  services.displayManager = {
    ly = {
      enable = true;
      x11Support = true;
    };
  };

  # user accounts
  users.users.${outputs.lib.username} = {
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
    microsoft-edge
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

  modules = {
    comma.enable = true;
    nix.enable = true;
    pipewire.enable = true;
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
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
