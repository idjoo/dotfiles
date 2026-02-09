# Dragon - GCP cloud VM home-manager configuration
# Based on ox, but without ox-specific services
{
  pkgs,
  outputs,
  config,
  ...
}:
{
  imports = [
    outputs.homeModules
  ];

  home = {
    username = "${outputs.lib.username}";
    homeDirectory = "/home/${outputs.lib.username}";

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
    nh.enable = true;
    stylix.enable = true;
    utils = {
      enable = true;
      nix.enable = true;
      cli.enable = true;
    };
    atuin.enable = true;
    direnv.enable = true;
    eza.enable = true;
    git = {
      enable = true;
      email = "vian@idjo.cc";
    };
    gpg.enable = true;
    lazygit.enable = true;
    neovim.enable = true;
    sops.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
    password-store.enable = true;
    ai = {
      enable = true;
      opencode.web.enable = true;
    };
  };

  systemd.user = {
    startServices = "sd-switch";
  };

  home.stateVersion = "23.11";
}
