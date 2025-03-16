{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    outputs.nixOnDroidModules
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
      allowUnfreePredicate = (pkg: true);
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trustedPublicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  user.shell = "${pkgs.zsh}/bin/zsh";

  terminal = {
    font = "${pkgs.nerd-fonts.roboto-mono}/share/fonts/truetype/NerdFonts/RobotoMono/RobotoMonoNerdFontMono-Regular.ttf";
    colors = {
      foreground = "#c6d0f5";
      background = "#293329";
      cursor = "#f2d5c7";
    };
  };

  modules = {
    android-integration.enable = true;
    utils.enable = true;
  };

  home-manager = {
    config = ./home.nix;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    backupFileExtension = "hm.bak";
  };

  # Set your time zone
  time.timeZone = "Asia/Jakarta";
}
