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

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
    inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./color.nix
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

  home = {
    username = "idjo";
    homeDirectory = "/home/idjo";
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;

  modules = {
    eza.enable = true;
    nvim.enable = true;
    wezterm.enable = true;
    zsh.enable = true;
    herbstluftwm.enable = true;
    rofi.enable = true;
    tmux.enable = true;
    polybar.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
