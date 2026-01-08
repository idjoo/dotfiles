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
    homeDirectory = "/Users/${outputs.username}";

    shell = {
      enableShellIntegration = false;
    };

    packages = with pkgs; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.log-streaming
        google-cloud-sdk.components.cloud-run-proxy
        google-cloud-sdk.components.run-compose
      ])
    ];
  };

  modules = {
    stylix.enable = true;

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
    gemini-cli.enable = true;
    claude-code.enable = true;
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
