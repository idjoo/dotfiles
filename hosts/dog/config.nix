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

    ./hardware.nix
    ./disko.nix
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # hostname
  networking.hostName = "dog";

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

  # timezone
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

    #desktopManager.xterm.enable = true;
    #displayManager.startx.enable = true;
    windowManager.herbstluftwm.enable = true;
  };

  services.displayManager = {
    ly = {
      enable = true;
      x11Support = true;
    };
  };

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

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
      "kvm"
    ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  # packages
  environment.systemPackages = with pkgs; [
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
    nix.enable = true;
    pipewire.enable = true;
    ssh.enable = true;
    stylix.enable = true;
    tailscale.enable = true;
    xremap.enable = true;
    utils = {
      enable = true;
      gui.enable = true;
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
