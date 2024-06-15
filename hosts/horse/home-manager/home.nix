{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
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

  home.packages = with pkgs; [
    (
      google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
      ]
    )
  ];

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
    # nvim.enable = true;
    neovim.enable = true;

    # launcher
    rofi.enable = true;

    # notification
    dunst.enable = true;

    # cli
    eza.enable = true;
    gpg.enable = true;
    git.enable = true;
    btop.enable = true;
    tmux.enable = true;
    lazygit.enable = true;
    password-store.enable = true;
    flameshot.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
