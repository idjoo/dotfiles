# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  pkgs,
  outputs,
  config,
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

  systemd.user = {
    # Nicely reload system units when changing configs
    startServices = "sd-switch";

    services = {
      whatsapp = {
        Unit = {
          Description = "Whatsapp Event Listener";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          WorkingDirectory = "${config.home.homeDirectory}/documents/whatsapp";
          ExecStart = "${config.home.homeDirectory}/documents/whatsapp/bin/whatsapp";
        };
      };
      lumpang-be = {
        Unit = {
          Description = "SiLumpang Backend";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          WorkingDirectory = "${config.home.homeDirectory}/documents/lumpang";
          ExecStart = "${config.home.homeDirectory}/documents/lumpang/.venv/bin/uvicorn api:app --port=8001";
        };
      };
      lumpang-fe = {
        Unit = {
          Description = "SiLumpang Frontend";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          WorkingDirectory = "${config.home.homeDirectory}/documents/lumpang";
          ExecStart = "${config.home.homeDirectory}/documents/lumpang/.venv/bin/streamlit run --browser.gatherUsageStats=false --server.port=8002 ui.py";
        };
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
