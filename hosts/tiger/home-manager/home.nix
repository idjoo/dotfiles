# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules
  ];

  programs.home-manager.enable = true;

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

  home = {
    username = "${outputs.username}";
    homeDirectory = "/home/${outputs.username}";
  };

  modules = {
    # window manager
    herbstluftwm.enable = true;

    # bar
    polybar.enable = true;

    # terminal
    wezterm.enable = true;

    # shell
    zsh.enable = true;

    # editor
    nvim.enable = true;

    # launcher
    rofi.enable = true;

    # cli
    eza.enable = true;
    gpg.enable = true;
    git.enable = true;
    password-store.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
