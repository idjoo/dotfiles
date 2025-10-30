{
  pkgs,
  outputs,
  ...
}:
{
  imports = [
    outputs.homeManagerModules
  ];

  programs.home-manager.enable = true;

  home = {
    username = "${outputs.username}";

    shell = {
      enableShellIntegration = false;
    };

    packages = with pkgs; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.log-streaming
      ])
    ];
  };

  modules = {
    # Terminal
    ghostty.enable = true;

    # Shell
    zsh.enable = true;

    # Editor
    neovim.enable = true;

    # Browser
    zen-browser.enable = true;

    # CLIs
    btop.enable = true;
    eza.enable = true;
    git = {
      enable = true;
      email = "adrianus.vian.habirowo@devoteam.com";
    };
    gpg.enable = true;
    lazygit.enable = true;
    password-store.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    fzf.enable = true;
    direnv.enable = true;
    zoxide.enable = true;
    atuin.enable = true;
    sops.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
