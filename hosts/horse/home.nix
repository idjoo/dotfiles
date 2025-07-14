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
    homeDirectory = "/home/${outputs.username}";

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
    # window manager
    herbstluftwm.enable = true;

    # bar
    polybar.enable = true;

    # terminal
    urxvt.enable = true;
    wezterm.enable = false;
    ghostty.enable = true;

    # shell
    zsh.enable = true;
    nushell.enable = true;

    # editor
    neovim.enable = true;

    # launcher
    rofi.enable = true;

    # notification
    dunst.enable = true;

    # browser
    firefox.enable = false;

    # cli
    btop.enable = true;
    eza.enable = true;
    flameshot.enable = true;
    git = {
      enable = true;
      email = "adrianus.vian.habirowo@devoteam.com";
    };
    gpg.enable = true;
    lazygit.enable = true;
    password-store.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    cava.enable = true;
    fzf.enable = true;
    direnv.enable = true;
    zoxide.enable = true;
    atuin.enable = true;

    # prog lang
    go.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
