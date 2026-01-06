{
  pkgs,
  config,
  outputs,
  ...
}:
{
  # List your module files here
  imports = [
    ./atuin
    ./btop
    ./cava
    ./claude-code
    ./direnv
    ./dunst
    ./eza
    ./firefox
    ./flameshot
    ./fzf
    ./gemini-cli
    ./ghostty
    ./git
    ./go
    ./gpg
    ./herbstluftwm
    ./lazygit
    ./mcp-servers
    ./neovim
    ./nushell
    ./password-store
    ./polybar
    ./qutebrowser
    ./rofi
    ./ssh
    ./sops
    ./tmux
    ./urxvt
    ./wezterm
    ./zen-browser
    ./zsh
    ./zoxide
  ];

  home.shellAliases = {
    rebuild =
      if pkgs.stdenv.isDarwin then
        "${pkgs.nh}/bin/nh darwin switch ~/Dotfiles"
      else
        "${pkgs.nh}/bin/nh os switch";
    n = "nvim ${config.home.homeDirectory}/note.md";
    c = "${pkgs.libqalculate}/bin/qalc";
    vim = "nvim";

    # nix
    nix-shell = "${pkgs.nix-output-monitor}/bin/nom-shell --command zsh";

    # work
    spindo-dev-dashboard = ''xdg-open "https://console.cloud.google.com/monitoring/dashboards/builder/afa6b769-7933-4f81-9d52-7735bfcb79a9;startTime=$(date -u -d yesterday +"%Y-%m-%dT10:30:00Z");endTime=$(date -u +"%Y-%m-%dT10:30:00Z")?project=prj-sap-dev-398404"'';
    spindo-prod-dashboard = ''xdg-open "https://console.cloud.google.com/monitoring/dashboards/builder/5deb3680-dcd5-4a70-8749-c84dfd2efcd3;startTime=$(date -u -d yesterday +"%Y-%m-%dT10:30:00Z");endTime=$(date -u +"%Y-%m-%dT10:30:00Z")?project=prj-sap-prod-398404"'';
    spindo-dev-snapshot = ''xdg-open "https://console.cloud.google.com/compute/snapshots?referrer=search&project=prj-sap-dev-398404&pageState=(%22snapshots%22:(%22s%22:%5B(%22i%22:%22creationTimestamp%22,%22s%22:%221%22),(%22i%22:%22name%22,%22s%22:%220%22)%5D))"'';
    spindo-prod-snapshot = ''xdg-open "https://console.cloud.google.com/compute/snapshots?referrer=search&project=prj-sap-prod-398404&pageState=(%22snapshots%22:(%22s%22:%5B(%22i%22:%22creationTimestamp%22,%22s%22:%221%22),(%22i%22:%22name%22,%22s%22:%220%22)%5D))"'';

    mount-gdrive = ''${pkgs.rclone} mount gdrive:/ ~/documents/drive'';

    # k8s
    kc = "${pkgs.kubectx}/bin/kubectx";
    kn = "${pkgs.kubectx}/bin/kubens";

    # gcloud
    gp = "gcloud projects list --format='value(projectId)' | ${pkgs.fzf}/bin/fzf --height=25% --layout=reverse --border | xargs -r gcloud config set project";
    ga = "gcloud auth list --format='value(account)' | ${pkgs.fzf}/bin/fzf --height=25% --layout=reverse --border | xargs -r gcloud config set account";
    gcurl = "curl -H \"Authorization: Bearer $(gcloud auth print-access-token)\"";

    # tmux
    t = "${pkgs.tmux}/bin/tmux";
    tn = "${pkgs.tmux}/bin/tmux new";
    ta = "${pkgs.tmux}/bin/tmux attach";

    # ssh
    horse = "TERM=xterm-256color ${pkgs.openssh}/bin/ssh ${outputs.username}@horse";
    ox = "TERM=xterm-256color ${pkgs.openssh}/bin/ssh ${outputs.username}@ox";
  };

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];
}

