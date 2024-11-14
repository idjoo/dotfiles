{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trustedPublicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

  time.timeZone = "Asia/Jakarta";

  environment.packages = with pkgs; [
    git
    neovim
    openssh
  ];

  environment.etcBackupExtension = ".bak";

  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm.bak";
    useGlobalPkgs = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
