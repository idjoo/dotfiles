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

  # hibernation: resume the previous session instead of cold-booting after
  # the battery dies. Requires swap >= RAM (15 GiB here) and, because the
  # swap is a file on ext4 root, an explicit resume_offset kernel param.
  #
  # First rebuild creates /var/lib/swapfile. Then run:
  #   sudo filefrag -v /var/lib/swapfile \
  #     | awk '$1=="0:" {sub(/\.\..*/,"",$4); print $4; exit}'
  # and replace PLACEHOLDER below with the printed number, then rebuild again.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # MiB, matches RAM
    }
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/bfe5b52b-c15c-4365-86c6-925c053f3244";
  # If the swapfile is ever recreated (resized, moved, or after disk repair),
  # re-measure with:
  #   sudo filefrag -v /var/lib/swapfile \
  #     | awk '$1=="0:" {sub(/\.\..*/,"",$4); print $4; exit}'
  boot.kernelParams = [ "resume_offset=33488896" ];

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

    displayManager.sessionCommands = ''
      ${pkgs.xset}/bin/xset s off
      ${pkgs.xset}/bin/xset -dpms
      ${pkgs.xset}/bin/xset s noblank
    '';

    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  services.displayManager = {
    ly = {
      enable = true;
      x11Support = true;
    };
  };

  services.logind.settings.Login = {
    # On AC: ignore the lid. On battery: suspend, then hibernate after the
    # delay set in systemd.sleep.extraConfig below.
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "ignore";
    IdleAction = "ignore";
  };

  # Suspend-then-hibernate timing: stay suspended (s2idle on this hardware)
  # for HibernateDelaySec, then transition to hibernate. 10m chosen because
  # s2idle drains faster than ACPI S3 and S3 isn't available here.
  # NOTE: setting HibernateDelaySec disables systemd's automatic low-battery
  # hibernation estimate; UPower's criticalPowerAction below covers the
  # awake-with-low-battery case instead.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "10m";
    SuspendState = "mem";
  };

  # When battery hits the action threshold while the system is awake,
  # hibernate directly so the next boot resumes the previous session.
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
    percentageLow = 15;
    percentageCritical = 7;
    percentageAction = 5;
    usePercentageForPolicy = true;
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

  # IPU6 webcam (Alder Lake ISP + OV2740 sensor). Kernel side enumerates
  # /dev/media0 and /dev/video0..31 but apps see "no camera" because IPU6
  # exposes raw ISYS streams, not UVC. This option pulls in the proprietary
  # intel-ipu6-camera-bins HAL, the libcamera IPU6 IPAs, and v4l2-relayd
  # which bridges IPU6 -> a virtual UVC node that browsers/Zoom can use.
  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };

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
