{
  pkgs,
  outputs,
  ...
}:
{
  imports = [
    outputs.homeModules
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.log-streaming
    ])
  ];

  modules = {
    nh.enable = true;

    # shell
    zsh.enable = true;

    # editor
    neovim.enable = true;

    # cli
    eza.enable = true;
    git = {
      enable = true;
      email = "vian@idjo.cc";
    };
    gpg.enable = true;
    lazygit.enable = true;
    password-store.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    #fzf.enable = true;
    #direnv.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
