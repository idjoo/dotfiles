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
    username = "${outputs.username}";
    homeDirectory = "/home/${outputs.username}";

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
    lazygit.enable = true;
    neovim.enable = true;
    sops.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
    password-store.enable = true;
    claude-code.enable = true;
    gemini-cli.enable = true;
    playwright.enable = true;
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
          Environment = [
            "GOOGLE_APPLICATION_CREDENTIALS=sa.json"
            "GOOGLE_CLOUD_PROJECT=lv-playground-genai"
            "GOOGLE_CLOUD_LOCATION=us-central1"
            "GOOGLE_GENAI_USE_VERTEXAI=TRUE"
          ];
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
      betting-calculator = {
        Unit = {
          Description = "Betting Calculator";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          WorkingDirectory = "${config.home.homeDirectory}/documents/betting/betting-calculator";
          ExecStart = "${pkgs.caddy}/bin/caddy run --config ${config.home.homeDirectory}/documents/betting/betting-calculator/Caddyfile";
        };
      };
      betting-api = {
        Unit = {
          Description = "Betting API";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          WorkingDirectory = "${config.home.homeDirectory}/documents/betting/betting-api";
          ExecStart = "${config.home.homeDirectory}/documents/betting/betting-api/.venv/bin/app";
        };
      };
      betting-dashboard = {
        Unit = {
          Description = "Betting Dashboard";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          WorkingDirectory = "${config.home.homeDirectory}/documents/betting/betting-dashboard";
          ExecStart = "${pkgs.bun}/bin/bun run start";
          Environment = [
            "API_URL=https://ox.wyvern-vector.ts.net/api/betting"
            "NEXT_PUBLIC_API_URL=https://ox.wyvern-vector.ts.net/api/betting"
          ];
        };
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
