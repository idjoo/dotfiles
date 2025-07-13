# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules
  ];

  home = {
    username = "idjo";
    homeDirectory = "/home/idjo";
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;

  modules = {
    eza.enable = true;
    lazygit.enable = true;
    neovim.enable = true;
    zsh.enable = true;
    direnv.enable = true;
    zoxide.enable = true;
    atuin.enable = true;
    git = {
      enable = true;
      email = "vian@idjo.cc";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
