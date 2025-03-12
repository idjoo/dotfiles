{
  inputs,
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    outputs.nixOnDroidModules
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  user.shell = "${pkgs.zsh}/bin/zsh";

  terminal = {
    font = "${pkgs.nerd-fonts.roboto-mono}/share/fonts/truetype/NerdFonts/RobotoMono/RobotoMonoNerdFontMono-Regular.ttf";
    colors = {
      foreground = "#c6d0f5";
      background = "#293329";
      cursor = "#f2d5c7";
    };
  };

  modules = {
    android-integration.enable = true;
    utils.enable = true;
  };

  home-manager = {
    config = ./home.nix;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };

  # Set your time zone
  time.timeZone = "Asia/Jakarta";
}
