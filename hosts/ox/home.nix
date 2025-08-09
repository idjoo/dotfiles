# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  pkgs,
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

    packages = with pkgs; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.log-streaming
      ])
    ];
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;

  modules = {
    atuin.enable = true;
    direnv.enable = true;
    eza.enable = true;
    git = {
      enable = true;
      email = "vian@idjo.cc";
    };
    lazygit.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
